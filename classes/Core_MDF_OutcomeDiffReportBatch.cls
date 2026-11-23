/*********************************************************************************************************************************************************************************
 * Class Name      : Core_MDF_OutcomeDiffReportBatch
 * Author          : Indu
 * Created Date    : Jul 3, 2026
 * Last Modified By: Indu
 * Last Modified On: Jul 3, 2026
 * Description     : This batch class generates the Outcome Based Activity difference report.
 *                   It compares Super Activities with related Sub Activities, validates funding split account,
 *                   funding split amount, requested amount, maximum Intel investment, and allocation mapping.
 *                   
 *
 * Change History  :
 *  Date          │   Author     │   Change
 * ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――
 *  Jul 3, 2026  │   Indu       │   Initial version
 *********************************************************************************************************************************************************************************/
global class Core_MDF_OutcomeDiffReportBatch
    implements Database.Batchable<SObject>, Database.Stateful, Core_MDF_BatchSchedulerInterface {

    public Id recordTrackingId;
    public List<String> csvDataList = new List<String>();

    public String createdDatePfr;
    public String trackingScopeName;
    public String groupDeveloperName;
    public String emailTemplateDeveloperName;

    global Core_MDF_OutcomeDiffReportBatch() {
        this.createdDatePfr = null;
        this.trackingScopeName = 'Outcome Based Activity Difference Report';
        this.groupDeveloperName = null;
        this.emailTemplateDeveloperName = null;
    }

    global Core_MDF_OutcomeDiffReportBatch(
        String createdDatePfr,
        String trackingScopeName,
        String groupDeveloperName,
        String emailTemplateDeveloperName
    ) {
        this.createdDatePfr = createdDatePfr;
        this.trackingScopeName = String.isNotBlank(trackingScopeName)
            ? trackingScopeName
            : 'Outcome Based Activity Difference Report';
        this.groupDeveloperName = groupDeveloperName;
        this.emailTemplateDeveloperName = emailTemplateDeveloperName;
    }

    public static Object generateInstance(String jsonText, String classSignature) {

        Map<String, Object> parmValueMap = new Map<String, Object>();

        if (String.isNotBlank(jsonText)) {
            parmValueMap = (Map<String, Object>) JSON.deserializeUntyped(jsonText);
        }

        String createdDatePfr = getStringParam(parmValueMap, 'createdDatePfr');
        String trackingScopeName = getStringParam(parmValueMap, 'trackingScopeName');
        String groupDeveloperName = getStringParam(parmValueMap, 'groupDeveloperName');
        String emailTemplateDeveloperName = getStringParam(parmValueMap, 'emailTemplateDeveloperName');

        return new Core_MDF_OutcomeDiffReportBatch(
            createdDatePfr,
            trackingScopeName,
            groupDeveloperName,
            emailTemplateDeveloperName
        );
    }

    private static String getStringParam(Map<String, Object> parmValueMap, String keyName) {
        if (parmValueMap == null || !parmValueMap.containsKey(keyName) || parmValueMap.get(keyName) == null) {
            return null;
        }

        String value = String.valueOf(parmValueMap.get(keyName));

        if (String.isBlank(value) || value == 'null') {
            return null;
        }

        return value;
    }

    private static Map<String, String> getCompareFields() {
        return new Map<String, String>{
            'RecordTypeId' => 'Record Type',
            'Core_MDF_Activity_Description__c' => 'Activity Description',
            'Core_MDF_Start_Date__c' => 'Start Date',
            'Core_MDF_End_Date__c' => 'End Date',
            'Core_MDF_Focus_Area_nm__c' => 'Focus Area',
            'Core_MDF_Budget_Type_nm__c' => 'Budget Type',
            'Core_MDF_Country_nm__c' => 'Country',
            'Core_MDF_Brand_nm__c' => 'Brand',
            'Core_MDF_Tactics_nm__c' => 'Tactics',
            'Core_MDF_TargetAudience_nm__c' => 'Target Audience',
            'Core_MDF_Initiative_nm__c' => 'Initiative',
            'Core_MDF_EcosystemPartner_nm__c' => 'Ecosystem Partner',
            'Core_MDF_Technology_txt__c' => 'Technology',
            'Core_MDF_Outcomes_nm__c' => 'Outcomes',
            'Core_MDF_Priority_nm__c' => 'Priority',
            'Core_MDF_Priority_2_nm__c' => 'Priority 2',
            'Core_MDF_ProductType__c' => 'Product Type',
            'Core_MDF_BU_Split__c' => 'BU Split',
            'Core_MDF_BU1_Split_Percent_nbr__c' => 'BU1 Split Percent',
            'Core_MDF_Outcome_Region_nm__c' => 'Outcome Region',
            'Core_MDF_Fund_Request_Status__c' => 'Fund Request Status',
            'Status' => 'Status',
            'Core_MDF_Reimbursement_Rate_txt__c' => 'Reimbursement Rate',
            'Core_MDF_Exchange_Rate_ptc__c' => 'Exchange Rate',
            'Core_MDF_Budget_Amount_Local_amt__c' => 'Total Investment (Intel + Partner)',
            'Core_MDF_Region_nm__c' => 'Region',
            'Core_MDF_Is_Outcome_Based_Ind__c' => 'Outcome Based Indicator'
        };
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {

        Date createdDateFilter;

        Set<String> superActivityFields = new Set<String>{
            'Id',
            'Title',
            'Core_MDF_Activity_Number__c',
            'Core_MDF_Is_Outcome_Based_Ind__c',
            'Core_MDF_Activity_Level_nm__c',
            'Core_MDF_Fund_Request_Status__c',
            'AllocationId',
            'CreatedDate',
            'CreatedById'
        };

        superActivityFields.addAll(getCompareFields().keySet());

        String query =
            'SELECT ' + String.join(new List<String>(superActivityFields), ',') +
            ' FROM PartnerFundRequest' +
            ' WHERE Core_MDF_Is_Outcome_Based_Ind__c = true' +
            ' AND Core_MDF_Fund_Request_Status__c != \'Cancelled\'' +
            ' AND (Core_MDF_Activity_Level_nm__c = null OR Core_MDF_Activity_Level_nm__c != \'Sub Activity\')';

        if (String.isNotBlank(createdDatePfr)) {
            createdDateFilter = Date.valueOf(createdDatePfr);
            query += ' AND DAY_ONLY(CreatedDate) = :createdDateFilter';
        }

        query += ' ORDER BY CreatedDate DESC';

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<SObject> scope) {

        List<PartnerFundRequest> superActivityList = new List<PartnerFundRequest>();

        for (SObject sobj : scope) {
            superActivityList.add((PartnerFundRequest) sobj);
        }

        if (superActivityList.isEmpty()) {
            return;
        }

        try {
            Map<Id, PartnerFundRequest> superActivityMap = new Map<Id, PartnerFundRequest>(superActivityList);
            Set<Id> superActivityIds = superActivityMap.keySet();

            Map<String, String> compareFields = getCompareFields();

            Set<String> subActivityFields = new Set<String>{
                'Id',
                'Core_MDF_Parent_Activity_Id__c',
                'Core_MDF_Activity_Number__c',
                'Title',
                'ChannelPartnerId',
                'ChannelPartner.Name',
                'AllocationId',
                'Amount',
                'RequestedAmount',
                'Core_MDF_Maximum_Intel_Investment_amt__c',
                'Core_MDF_Fund_Request_Status__c',
                'Core_MDF_Activity_Level_nm__c'
            };

            subActivityFields.addAll(compareFields.keySet());

            String subQuery =
                'SELECT ' + String.join(new List<String>(subActivityFields), ',') +
                ' FROM PartnerFundRequest' +
                ' WHERE Core_MDF_Parent_Activity_Id__c IN :superActivityIds' +
                ' AND Core_MDF_Activity_Level_nm__c = \'Sub Activity\'' +
                ' AND Core_MDF_Fund_Request_Status__c != \'Cancelled\'';

            List<PartnerFundRequest> subActivityList = Database.query(subQuery);

            List<Core_MDF_Outcome_Account_Mapping__c> fundingSplitList = [
                SELECT Id,
                       Core_MDF_Outcome_Based_CampaignId__c,
                       Core_MDF_AccountId__c,
                       Core_MDF_AccountId__r.Name,
                       Core_MDF_Percentage_pct__c,
                       Core_MDF_Amount_nbr__c,
                       Core_MDF_Active_Ind__c,
                       Core_MDF_OutcomeBased_SubAct_Id__c
                FROM Core_MDF_Outcome_Account_Mapping__c
                WHERE Core_MDF_Outcome_Based_CampaignId__c IN :superActivityIds
                AND Core_MDF_Active_Ind__c = true
            ];

            List<Core_MDF_OutcomeDiffReportWrapper> diffRows = new List<Core_MDF_OutcomeDiffReportWrapper>();

            Map<Id, List<PartnerFundRequest>> superIdToSubActivities = new Map<Id, List<PartnerFundRequest>>();
            Map<String, PartnerFundRequest> superAccountKeyToSubActivity = new Map<String, PartnerFundRequest>();
            Map<Id, PartnerFundRequest> subIdToSubActivity = new Map<Id, PartnerFundRequest>();

            for (PartnerFundRequest subAct : subActivityList) {

                if (!superIdToSubActivities.containsKey(subAct.Core_MDF_Parent_Activity_Id__c)) {
                    superIdToSubActivities.put(subAct.Core_MDF_Parent_Activity_Id__c, new List<PartnerFundRequest>());
                }

                superIdToSubActivities.get(subAct.Core_MDF_Parent_Activity_Id__c).add(subAct);
                subIdToSubActivity.put(subAct.Id, subAct);

                String accountKey = buildKey(subAct.Core_MDF_Parent_Activity_Id__c, subAct.ChannelPartnerId);

                if (superAccountKeyToSubActivity.containsKey(accountKey)) {
                    PartnerFundRequest superAct = superActivityMap.get(subAct.Core_MDF_Parent_Activity_Id__c);

                    diffRows.add(buildRow(
                        'Duplicate Sub Activity For Account',
                        superAct,
                        subAct,
                        null,
                        'ChannelPartnerId',
                        'Sub Activity Account',
                        'Only one active Sub Activity should exist for this account',
                        getAccountDisplay(subAct.ChannelPartnerId, subAct.ChannelPartner != null ? subAct.ChannelPartner.Name : null)
                    ));
                } else {
                    superAccountKeyToSubActivity.put(accountKey, subAct);
                }
            }

            Map<String, Core_MDF_Outcome_Account_Mapping__c> superAccountKeyToFundingSplit =
                new Map<String, Core_MDF_Outcome_Account_Mapping__c>();

            Set<Id> fundingSplitAccountIds = new Set<Id>();

            for (Core_MDF_Outcome_Account_Mapping__c fundingSplit : fundingSplitList) {

                String accountKey = buildKey(
                    fundingSplit.Core_MDF_Outcome_Based_CampaignId__c,
                    fundingSplit.Core_MDF_AccountId__c
                );

                if (superAccountKeyToFundingSplit.containsKey(accountKey)) {
                    PartnerFundRequest superAct = superActivityMap.get(fundingSplit.Core_MDF_Outcome_Based_CampaignId__c);

                    diffRows.add(buildRow(
                        'Duplicate Funding Split For Account',
                        superAct,
                        null,
                        fundingSplit,
                        'Core_MDF_AccountId__c',
                        'Funding Split Account',
                        'Only one active funding split should exist for this account',
                        getAccountDisplay(
                            fundingSplit.Core_MDF_AccountId__c,
                            fundingSplit.Core_MDF_AccountId__r != null ? fundingSplit.Core_MDF_AccountId__r.Name : null
                        )
                    ));
                } else {
                    superAccountKeyToFundingSplit.put(accountKey, fundingSplit);
                }

                if (fundingSplit.Core_MDF_AccountId__c != null) {
                    fundingSplitAccountIds.add(fundingSplit.Core_MDF_AccountId__c);
                }
            }

            Map<Id, PartnerFundAllocation> allocationIdToAllocation = new Map<Id, PartnerFundAllocation>();

            Map<Id, PartnerFundAllocation> parentAllocationMap = getParentAllocationMap(superActivityList);
            allocationIdToAllocation.putAll(parentAllocationMap);

            Map<String, PartnerFundAllocation> budgetAccountToAllocation =
                getBudgetAccountToAllocationMap(parentAllocationMap, fundingSplitAccountIds);

            for (PartnerFundAllocation expectedAllocation : budgetAccountToAllocation.values()) {
                allocationIdToAllocation.put(expectedAllocation.Id, expectedAllocation);
            }

            addSubAllocationDetails(subActivityList, allocationIdToAllocation);

            compareParentAndSubFields(
                superActivityMap,
                subActivityList,
                compareFields,
                superAccountKeyToFundingSplit,
                diffRows
            );

            compareFundingSplitsAndSubActivities(
                superActivityMap,
                fundingSplitList,
                superAccountKeyToSubActivity,
                subIdToSubActivity,
                parentAllocationMap,
                budgetAccountToAllocation,
                allocationIdToAllocation,
                diffRows
            );

            compareExtraSubActivities(
                superActivityMap,
                subActivityList,
                superAccountKeyToFundingSplit,
                diffRows
            );

            if (!diffRows.isEmpty()) {
                csvDataList.addAll(generateCSV(diffRows));
            }

        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }

    global void finish(Database.BatchableContext bc) {

        try {
            if (csvDataList == null || csvDataList.isEmpty()) {
                return;
            }

            if (recordTrackingId == null) {
                Core_MDF_Record_Tracking__c rt = new Core_MDF_Record_Tracking__c();
                rt.Core_MDF_Scope_nm__c = String.isNotBlank(trackingScopeName)
                    ? trackingScopeName
                    : 'Outcome Based Activity Difference Report';

                Database.SaveResult insertedRecord = Database.insert(rt);

                if (insertedRecord != null && insertedRecord.isSuccess()) {
                    recordTrackingId = insertedRecord.getId();
                }
            }

            if (recordTrackingId == null) {
                return;
            }

            String csvHeader =
                'Difference Type,' +
                'Super Activity Id,' +
                'Super Activity Number,' +
                'Super Activity Title,' +
                'Account Id,' +
                'Account Name,' +
                'Sub Activity Id,' +
                'Sub Activity Number,' +
                'Sub Activity Title,' +
                'Funding Split Record Id,' +
                'Funding Split Percent,' +
                'Funding Split Amount,' +
                'Field API Name,' +
                'Field Label,' +
                'Expected Value,' +
                'Actual Value,' +
                'Super Activity CreatedDate,' +
                'Super Activity CreatedById';

            csvDataList.add(0, csvHeader);

            ContentVersion cv = createContentVersion(csvDataList);
            insert cv;

            saveAttachment(new Set<Id>{cv.Id});
            sendEmail();

        } catch (Exception ex) {
            Core_MDF_CCP_UtilityClass.logError(ex);
        }
    }

    private static void compareParentAndSubFields(
        Map<Id, PartnerFundRequest> superActivityMap,
        List<PartnerFundRequest> subActivityList,
        Map<String, String> compareFields,
        Map<String, Core_MDF_Outcome_Account_Mapping__c> superAccountKeyToFundingSplit,
        List<Core_MDF_OutcomeDiffReportWrapper> diffRows
    ) {
        for (PartnerFundRequest subAct : subActivityList) {

            PartnerFundRequest superAct = superActivityMap.get(subAct.Core_MDF_Parent_Activity_Id__c);

            if (superAct == null) {
                continue;
            }

            String accountKey = buildKey(subAct.Core_MDF_Parent_Activity_Id__c, subAct.ChannelPartnerId);
            Core_MDF_Outcome_Account_Mapping__c fundingSplit = superAccountKeyToFundingSplit.get(accountKey);

            for (String fieldApi : compareFields.keySet()) {

                Object expectedValue = superAct.get(fieldApi);
                Object actualValue = subAct.get(fieldApi);

                if (areDifferent(expectedValue, actualValue)) {
                    diffRows.add(buildRow(
                        'Parent/Sub Field Difference',
                        superAct,
                        subAct,
                        fundingSplit,
                        fieldApi,
                        compareFields.get(fieldApi),
                        expectedValue,
                        actualValue
                    ));
                }
            }
        }
    }

    private static void compareFundingSplitsAndSubActivities(
        Map<Id, PartnerFundRequest> superActivityMap,
        List<Core_MDF_Outcome_Account_Mapping__c> fundingSplitList,
        Map<String, PartnerFundRequest> superAccountKeyToSubActivity,
        Map<Id, PartnerFundRequest> subIdToSubActivity,
        Map<Id, PartnerFundAllocation> parentAllocationMap,
        Map<String, PartnerFundAllocation> budgetAccountToAllocation,
        Map<Id, PartnerFundAllocation> allocationIdToAllocation,
        List<Core_MDF_OutcomeDiffReportWrapper> diffRows
    ) {
        for (Core_MDF_Outcome_Account_Mapping__c fundingSplit : fundingSplitList) {

            PartnerFundRequest superAct = superActivityMap.get(fundingSplit.Core_MDF_Outcome_Based_CampaignId__c);

            if (superAct == null) {
                continue;
            }

            String accountKey = buildKey(
                fundingSplit.Core_MDF_Outcome_Based_CampaignId__c,
                fundingSplit.Core_MDF_AccountId__c
            );

            PartnerFundRequest subAct = superAccountKeyToSubActivity.get(accountKey);

            if (subAct == null) {
                diffRows.add(buildRow(
                    'Missing Sub Activity',
                    superAct,
                    null,
                    fundingSplit,
                    'ChannelPartnerId',
                    'Sub Activity Account',
                    getAccountDisplay(
                        fundingSplit.Core_MDF_AccountId__c,
                        fundingSplit.Core_MDF_AccountId__r != null ? fundingSplit.Core_MDF_AccountId__r.Name : null
                    ),
                    null
                ));
                continue;
            }

            if (fundingSplit.Core_MDF_OutcomeBased_SubAct_Id__c == null) {
                diffRows.add(buildRow(
                    'Funding Split Sub Activity Missing',
                    superAct,
                    subAct,
                    fundingSplit,
                    'Core_MDF_OutcomeBased_SubAct_Id__c',
                    'Funding Split Stored Sub Activity',
                    subAct.Core_MDF_Activity_Number__c,
                    null
                ));
            } else if (fundingSplit.Core_MDF_OutcomeBased_SubAct_Id__c != subAct.Id) {

                PartnerFundRequest storedSub = subIdToSubActivity.get(fundingSplit.Core_MDF_OutcomeBased_SubAct_Id__c);

                diffRows.add(buildRow(
                    'Funding Split Sub Activity Difference',
                    superAct,
                    subAct,
                    fundingSplit,
                    'Core_MDF_OutcomeBased_SubAct_Id__c',
                    'Funding Split Stored Sub Activity',
                    subAct.Core_MDF_Activity_Number__c,
                    storedSub != null ? storedSub.Core_MDF_Activity_Number__c : String.valueOf(fundingSplit.Core_MDF_OutcomeBased_SubAct_Id__c)
                ));
            }

            if (fundingSplit.Core_MDF_OutcomeBased_SubAct_Id__c != null) {
                PartnerFundRequest storedSub = subIdToSubActivity.get(fundingSplit.Core_MDF_OutcomeBased_SubAct_Id__c);

                if (storedSub == null) {
                    diffRows.add(buildRow(
                        'Stored Sub Activity Missing Or Cancelled',
                        superAct,
                        subAct,
                        fundingSplit,
                        'Core_MDF_OutcomeBased_SubAct_Id__c',
                        'Stored Sub Activity',
                        String.valueOf(fundingSplit.Core_MDF_OutcomeBased_SubAct_Id__c),
                        null
                    ));
                } else if (storedSub.ChannelPartnerId != fundingSplit.Core_MDF_AccountId__c) {
                    diffRows.add(buildRow(
                        'Stored Sub Activity Account Difference',
                        superAct,
                        storedSub,
                        fundingSplit,
                        'ChannelPartnerId',
                        'Stored Sub Activity Account',
                        getAccountDisplay(
                            fundingSplit.Core_MDF_AccountId__c,
                            fundingSplit.Core_MDF_AccountId__r != null ? fundingSplit.Core_MDF_AccountId__r.Name : null
                        ),
                        getAccountDisplay(
                            storedSub.ChannelPartnerId,
                            storedSub.ChannelPartner != null ? storedSub.ChannelPartner.Name : null
                        )
                    ));
                }
            }

            compareAmountField(
                superAct,
                subAct,
                fundingSplit,
                'Amount',
                'Sub Activity Amount',
                fundingSplit.Core_MDF_Amount_nbr__c,
                subAct.Amount,
                diffRows
            );

            compareAmountField(
                superAct,
                subAct,
                fundingSplit,
                'RequestedAmount',
                'Requested Amount',
                fundingSplit.Core_MDF_Amount_nbr__c,
                subAct.RequestedAmount,
                diffRows
            );

            compareAmountField(
                superAct,
                subAct,
                fundingSplit,
                'Core_MDF_Maximum_Intel_Investment_amt__c',
                'Maximum Intel Investment',
                fundingSplit.Core_MDF_Amount_nbr__c,
                subAct.Core_MDF_Maximum_Intel_Investment_amt__c,
                diffRows
            );

            PartnerFundAllocation expectedAllocation = getExpectedAllocation(
                superAct,
                fundingSplit,
                parentAllocationMap,
                budgetAccountToAllocation
            );

            String actualAllocationDisplay = getAllocationDisplay(
                subAct.AllocationId,
                allocationIdToAllocation
            );

            if (superAct.AllocationId == null) {
                diffRows.add(buildRow(
                    'Parent Allocation Missing',
                    superAct,
                    subAct,
                    fundingSplit,
                    'AllocationId',
                    'Parent Allocation',
                    'Parent Allocation should be populated',
                    ''
                ));
            } else if (expectedAllocation == null) {
                diffRows.add(buildRow(
                    'Missing Account Allocation',
                    superAct,
                    subAct,
                    fundingSplit,
                    'AllocationId',
                    'Sub Activity Allocation',
                    'Allocation for parent budget and funding split account',
                    actualAllocationDisplay
                ));
            } else if (subAct.AllocationId != expectedAllocation.Id) {
                String expectedAllocationDisplay = getAllocationDisplay(
                    expectedAllocation.Id,
                    allocationIdToAllocation
                );

                diffRows.add(buildRow(
                    'Allocation Difference',
                    superAct,
                    subAct,
                    fundingSplit,
                    'AllocationId',
                    'Sub Activity Allocation',
                    expectedAllocationDisplay,
                    actualAllocationDisplay
                ));
            }
        }
    }

    private static void compareExtraSubActivities(
        Map<Id, PartnerFundRequest> superActivityMap,
        List<PartnerFundRequest> subActivityList,
        Map<String, Core_MDF_Outcome_Account_Mapping__c> superAccountKeyToFundingSplit,
        List<Core_MDF_OutcomeDiffReportWrapper> diffRows
    ) {
        for (PartnerFundRequest subAct : subActivityList) {

            PartnerFundRequest superAct = superActivityMap.get(subAct.Core_MDF_Parent_Activity_Id__c);

            if (superAct == null) {
                continue;
            }

            String accountKey = buildKey(subAct.Core_MDF_Parent_Activity_Id__c, subAct.ChannelPartnerId);

            if (!superAccountKeyToFundingSplit.containsKey(accountKey)) {
                diffRows.add(buildRow(
                    'Extra Sub Activity',
                    superAct,
                    subAct,
                    null,
                    'ChannelPartnerId',
                    'Sub Activity Account',
                    'Active funding split should exist for this account',
                    getAccountDisplay(
                        subAct.ChannelPartnerId,
                        subAct.ChannelPartner != null ? subAct.ChannelPartner.Name : null
                    )
                ));
            }
        }
    }

    private static void compareAmountField(
        PartnerFundRequest superAct,
        PartnerFundRequest subAct,
        Core_MDF_Outcome_Account_Mapping__c fundingSplit,
        String fieldApiName,
        String fieldLabel,
        Decimal expectedAmount,
        Decimal actualAmount,
        List<Core_MDF_OutcomeDiffReportWrapper> diffRows
    ) {
        if (decimalDifferent(expectedAmount, actualAmount)) {
            diffRows.add(buildRow(
                'Split Amount Difference',
                superAct,
                subAct,
                fundingSplit,
                fieldApiName,
                fieldLabel,
                expectedAmount,
                actualAmount
            ));
        }
    }

    private static Map<Id, PartnerFundAllocation> getParentAllocationMap(List<PartnerFundRequest> superActivityList) {

        Set<Id> parentAllocationIds = new Set<Id>();

        for (PartnerFundRequest superAct : superActivityList) {
            if (superAct.AllocationId != null) {
                parentAllocationIds.add(superAct.AllocationId);
            }
        }

        if (parentAllocationIds.isEmpty()) {
            return new Map<Id, PartnerFundAllocation>();
        }

        return new Map<Id, PartnerFundAllocation>([
            SELECT Id, Title, BudgetId, ChannelPartnerId
            FROM PartnerFundAllocation
            WHERE Id IN :parentAllocationIds
        ]);
    }

    private static Map<String, PartnerFundAllocation> getBudgetAccountToAllocationMap(
        Map<Id, PartnerFundAllocation> parentAllocationMap,
        Set<Id> fundingSplitAccountIds
    ) {
        Map<String, PartnerFundAllocation> budgetAccountToAllocation =
            new Map<String, PartnerFundAllocation>();

        if (
            parentAllocationMap == null ||
            parentAllocationMap.isEmpty() ||
            fundingSplitAccountIds == null ||
            fundingSplitAccountIds.isEmpty()
        ) {
            return budgetAccountToAllocation;
        }

        Set<Id> budgetIds = new Set<Id>();

        for (PartnerFundAllocation parentAllocation : parentAllocationMap.values()) {
            if (parentAllocation.BudgetId != null) {
                budgetIds.add(parentAllocation.BudgetId);
            }
        }

        if (budgetIds.isEmpty()) {
            return budgetAccountToAllocation;
        }

        for (PartnerFundAllocation accountAllocation : [
            SELECT Id, Title, BudgetId, ChannelPartnerId
            FROM PartnerFundAllocation
            WHERE BudgetId IN :budgetIds
            AND ChannelPartnerId IN :fundingSplitAccountIds
        ]) {
            String key = buildKey(accountAllocation.BudgetId, accountAllocation.ChannelPartnerId);
            budgetAccountToAllocation.put(key, accountAllocation);
        }

        return budgetAccountToAllocation;
    }

    private static void addSubAllocationDetails(
        List<PartnerFundRequest> subActivityList,
        Map<Id, PartnerFundAllocation> allocationIdToAllocation
    ) {
        Set<Id> subAllocationIds = new Set<Id>();

        for (PartnerFundRequest subAct : subActivityList) {
            if (subAct.AllocationId != null && !allocationIdToAllocation.containsKey(subAct.AllocationId)) {
                subAllocationIds.add(subAct.AllocationId);
            }
        }

        if (subAllocationIds.isEmpty()) {
            return;
        }

        for (PartnerFundAllocation subAllocation : [
            SELECT Id, Title, BudgetId, ChannelPartnerId
            FROM PartnerFundAllocation
            WHERE Id IN :subAllocationIds
        ]) {
            allocationIdToAllocation.put(subAllocation.Id, subAllocation);
        }
    }

    private static PartnerFundAllocation getExpectedAllocation(
        PartnerFundRequest superAct,
        Core_MDF_Outcome_Account_Mapping__c fundingSplit,
        Map<Id, PartnerFundAllocation> parentAllocationMap,
        Map<String, PartnerFundAllocation> budgetAccountToAllocation
    ) {
        if (
            superAct == null ||
            superAct.AllocationId == null ||
            fundingSplit == null ||
            fundingSplit.Core_MDF_AccountId__c == null
        ) {
            return null;
        }

        PartnerFundAllocation parentAllocation = parentAllocationMap.get(superAct.AllocationId);

        if (parentAllocation == null || parentAllocation.BudgetId == null) {
            return null;
        }

        String key = buildKey(parentAllocation.BudgetId, fundingSplit.Core_MDF_AccountId__c);

        return budgetAccountToAllocation.get(key);
    }

    private static Core_MDF_OutcomeDiffReportWrapper buildRow(
        String differenceType,
        PartnerFundRequest superAct,
        PartnerFundRequest subAct,
        Core_MDF_Outcome_Account_Mapping__c fundingSplit,
        String fieldApiName,
        String fieldLabel,
        Object expectedValue,
        Object actualValue
    ) {
        Core_MDF_OutcomeDiffReportWrapper row = new Core_MDF_OutcomeDiffReportWrapper();

        row.differenceType = differenceType;

        if (superAct != null) {
            row.superActivityId = superAct.Id;
            row.superActivityNumber = superAct.Core_MDF_Activity_Number__c;
            row.superActivityTitle = superAct.Title;
            row.superActivityCreatedDate = superAct.CreatedDate;
            row.superActivityCreatedById = superAct.CreatedById;
        }

        if (fundingSplit != null) {
            row.fundingSplitRecordId = fundingSplit.Id;
            row.accountId = fundingSplit.Core_MDF_AccountId__c;
            row.accountName = fundingSplit.Core_MDF_AccountId__r != null
                ? fundingSplit.Core_MDF_AccountId__r.Name
                : null;
            row.fundingSplitPercent = fundingSplit.Core_MDF_Percentage_pct__c;
            row.fundingSplitAmount = fundingSplit.Core_MDF_Amount_nbr__c;
        }

        if (subAct != null) {
            row.subActivityId = subAct.Id;
            row.subActivityNumber = subAct.Core_MDF_Activity_Number__c;
            row.subActivityTitle = subAct.Title;

            if (row.accountId == null) {
                row.accountId = subAct.ChannelPartnerId;
            }

            if (String.isBlank(row.accountName)) {
                row.accountName = subAct.ChannelPartner != null
                    ? subAct.ChannelPartner.Name
                    : null;
            }
        }

        row.fieldApiName = fieldApiName;
        row.fieldLabel = fieldLabel;
        row.expectedValue = stringify(expectedValue);
        row.actualValue = stringify(actualValue);

        return row;
    }

    public static List<String> generateCSV(List<Core_MDF_OutcomeDiffReportWrapper> reportWrapList) {

        List<String> csvList = new List<String>();

        if (reportWrapList == null || reportWrapList.isEmpty()) {
            return csvList;
        }

        for (Core_MDF_OutcomeDiffReportWrapper wrapper : reportWrapList) {

            String csvContent =
                csv(wrapper.differenceType) + ',' +
                csv(wrapper.superActivityId) + ',' +
                csv(wrapper.superActivityNumber) + ',' +
                csv(wrapper.superActivityTitle) + ',' +
                csv(wrapper.accountId) + ',' +
                csv(wrapper.accountName) + ',' +
                csv(wrapper.subActivityId) + ',' +
                csv(wrapper.subActivityNumber) + ',' +
                csv(wrapper.subActivityTitle) + ',' +
                csv(wrapper.fundingSplitRecordId) + ',' +
                csv(wrapper.fundingSplitPercent) + ',' +
                csv(wrapper.fundingSplitAmount) + ',' +
                csv(wrapper.fieldApiName) + ',' +
                csv(wrapper.fieldLabel) + ',' +
                csv(wrapper.expectedValue) + ',' +
                csv(wrapper.actualValue) + ',' +
                csv(wrapper.superActivityCreatedDate) + ',' +
                csv(wrapper.superActivityCreatedById);

            csvList.add(csvContent);
        }

        return csvList;
    }

    public ContentVersion createContentVersion(List<String> csvDataList) {
        ContentVersion cv = new ContentVersion();
        cv.Title = 'OutcomeBasedActivityDifferenceReport.csv';
        cv.PathOnClient = 'OutcomeBasedActivityDifferenceReport.csv';
        cv.VersionData = Blob.valueOf(String.join(csvDataList, '\n'));
        return cv;
    }

    public void saveAttachment(Set<Id> contentVersionIds) {

        if (recordTrackingId == null || contentVersionIds == null || contentVersionIds.isEmpty()) {
            return;
        }

        List<ContentDocumentLink> contentDocLinkList = new List<ContentDocumentLink>();

        for (ContentDocument contentDoc : [
            SELECT Id
            FROM ContentDocument
            WHERE LatestPublishedVersionId IN :contentVersionIds
        ]) {
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = contentDoc.Id;
            cdl.LinkedEntityId = recordTrackingId;
            cdl.ShareType = 'V';
            cdl.Visibility = 'InternalUsers';
            contentDocLinkList.add(cdl);
        }

        if (!contentDocLinkList.isEmpty()) {
            insert contentDocLinkList;
        }
    }

    private void sendEmail() {

        if (
            String.isBlank(emailTemplateDeveloperName) ||
            String.isBlank(groupDeveloperName) ||
            recordTrackingId == null
        ) {
            return;
        }

        Set<Id> userIds = getUserIdsFromGroup(groupDeveloperName);

        if (userIds.isEmpty()) {
            return;
        }

        List<EmailTemplate> templateList = [
            SELECT Id, HtmlValue, Subject
            FROM EmailTemplate
            WHERE DeveloperName = :emailTemplateDeveloperName
            LIMIT 1
        ];

        if (templateList.isEmpty()) {
            return;
        }

        List<Messaging.SingleEmailMessage> emailsToBeSent = new List<Messaging.SingleEmailMessage>();

        for (User usr : [
            SELECT Id
            FROM User
            WHERE Id IN :userIds
            AND IsActive = true
        ]) {
            Messaging.SingleEmailMessage sendEmail = new Messaging.SingleEmailMessage();
            sendEmail.setWhatId(recordTrackingId);
            sendEmail.setTemplateId(templateList[0].Id);
            sendEmail.setTargetObjectId(usr.Id);
            sendEmail.setSaveAsActivity(false);
            sendEmail.setOrgWideEmailAddressId(Label.Core_MDF_OrgWideId);
            emailsToBeSent.add(sendEmail);
        }

        if (!emailsToBeSent.isEmpty()) {
            Core_MDF_GenericClassToSendMail.sendEmails(emailsToBeSent);
        }
    }

    private static Set<Id> getUserIdsFromGroup(String groupDeveloperName) {

        Set<Id> userIds = new Set<Id>();

        if (String.isBlank(groupDeveloperName)) {
            return userIds;
        }

        List<Group> groupList = [
            SELECT Id
            FROM Group
            WHERE DeveloperName = :groupDeveloperName
            LIMIT 1
        ];

        if (groupList.isEmpty()) {
            return userIds;
        }

        Set<Id> processedGroupIds = new Set<Id>();
        Set<Id> groupIdsToProcess = new Set<Id>{ groupList[0].Id };

        while (!groupIdsToProcess.isEmpty()) {

            Set<Id> currentGroupIds = new Set<Id>();
            currentGroupIds.addAll(groupIdsToProcess);
            groupIdsToProcess.clear();

            for (GroupMember gm : [
                SELECT GroupId, UserOrGroupId
                FROM GroupMember
                WHERE GroupId IN :currentGroupIds
            ]) {
                String memberId = String.valueOf(gm.UserOrGroupId);

                if (memberId.startsWith('005')) {
                    userIds.add(gm.UserOrGroupId);
                } else if (memberId.startsWith('00G') && !processedGroupIds.contains(gm.UserOrGroupId)) {
                    groupIdsToProcess.add(gm.UserOrGroupId);
                }
            }

            processedGroupIds.addAll(currentGroupIds);
        }

        return userIds;
    }

    private static String getAllocationDisplay(
        Id allocationId,
        Map<Id, PartnerFundAllocation> allocationIdToAllocation
    ) {
        if (allocationId == null) {
            return '';
        }

        if (
            allocationIdToAllocation != null &&
            allocationIdToAllocation.containsKey(allocationId) &&
            allocationIdToAllocation.get(allocationId) != null
        ) {
            PartnerFundAllocation allocationRec = allocationIdToAllocation.get(allocationId);

            if (String.isNotBlank(allocationRec.Title)) {
                return allocationRec.Title;
            }
        }

        return String.valueOf(allocationId);
    }

    private static String getAccountDisplay(Id accountId, String accountName) {
        if (String.isNotBlank(accountName)) {
            return accountName;
        }

        return accountId != null ? String.valueOf(accountId) : '';
    }

    private static String buildKey(Object firstValue, Object secondValue) {
        return stringify(firstValue) + '-' + stringify(secondValue);
    }

    private static Boolean decimalDifferent(Decimal expectedValue, Decimal actualValue) {
        if (expectedValue == null && actualValue == null) {
            return false;
        }

        if (expectedValue == null || actualValue == null) {
            return true;
        }

        return expectedValue != actualValue;
    }

    private static Boolean areDifferent(Object expectedValue, Object actualValue) {
        if (expectedValue == null && actualValue == null) {
            return false;
        }

        if (expectedValue == null || actualValue == null) {
            return true;
        }

        if (expectedValue instanceof Decimal && actualValue instanceof Decimal) {
            return ((Decimal) expectedValue) != ((Decimal) actualValue);
        }

        return stringify(expectedValue) != stringify(actualValue);
    }

    private static String stringify(Object valueObj) {
        if (valueObj == null) {
            return '';
        }

        return String.valueOf(valueObj).trim();
    }

    private static String csv(Object valueObj) {
        String value = stringify(valueObj);
        value = value.replace('"', '""');
        return '"' + value + '"';
    }
}