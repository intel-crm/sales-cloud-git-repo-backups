/***************************************************************************************************** 
Class Name   :    Core_MDF_OutcomeBasedCmpgnTab
Description  :    Server-side controller of Core_MDF_outcomebasedtablwc
Added By     :    Ramapriya - Weezer
Created Date :    12/12/2025
******************************************************************************************************/
public with sharing class Core_MDF_OutcomeBasedCmpgnTab{
    
    // Existing inner class
    public class ListViewOption {  
        @AuraEnabled public String id; 
        @AuraEnabled public String label; 
        public ListViewOption(String id, String label) {
            this.id = id; 
            this.label = label; 
        } 
    }

    // Existing whitelist for PartnerFundRequest
    private static final Set<String> SORTABLE_FIELDS = new Set<String>{
        'Title','Core_MDF_Fund_Request_Status__c','Amount','Core_MDF_Start_and_End_Date','LastModifiedDate'
    };

    // Updated whitelist for outcome-based campaigns
    private static final Set<String> ACTIVITY_SORTABLE_FIELDS = new Set<String>{
        'Title','Core_MDF_Fund_Request_Status__c','Core_MDF_Maximum_Intel_Investment_amt__c','Core_MDF_Activity_Number__c','Core_MDF_Start_Date_End_Date__c','LastModifiedDate','ChannelPartner.Name'
    };

    private static final Integer DEFAULT_ACTIVITY_PAGE_SIZE = 1000;
    private static final Integer MAX_ACTIVITY_PAGE_SIZE = 2000;

    
    @AuraEnabled(cacheable=true)
    public static List<ListViewOption> getListViews(String objectApiName) {
        if (String.isBlank(objectApiName)) {
            throw new AuraHandledException('objectApiName is required');
        }

        List<ListView> views = [
            SELECT Id, Name, DeveloperName, SobjectType, IsSoqlCompatible
            FROM ListView
            WHERE SobjectType = :objectApiName
            AND IsSoqlCompatible = true
            ORDER BY Name
        ];

        List<ListViewOption> options = new List<ListViewOption>();
        for (ListView lv : views) {
            options.add(new ListViewOption(lv.Id, lv.Name));
        }
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static List<PartnerFundRequest> getAllOutcomeBasedCampaigns(Integer limitSize, String sortBy, String sortDir) {
        Integer lim = (limitSize == null || limitSize <= 0) ? 50 : limitSize;
        String orderField = String.isBlank(sortBy) ? 'LastModifiedDate' : sortBy;
        if (!SORTABLE_FIELDS.contains(orderField)) {
            orderField = 'LastModifiedDate';
        }
        String direction = (String.isBlank(sortDir) || sortDir.toLowerCase() != 'asc') ? 'DESC' : 'ASC';

        String base = 'SELECT Id, Title, Core_MDF_Fund_Request_Status__c, Amount,Core_MDF_Start_Date_End_Date__c, Owner.Id, Owner.Name ' +
                      'FROM PartnerFundRequest ' +
                      'ORDER BY ' + orderField + ' ' + direction +
                      ' LIMIT :lim';

        return Database.query(base);
    }

    @AuraEnabled(cacheable=true)
    public static List<PartnerFundRequest> getListViewRows(String listViewId, Integer limitSize, String sortBy, String sortDir) {
        if (String.isBlank(listViewId)) {
            throw new AuraHandledException('listViewId is required');
        }

        Integer lim = (limitSize == null || limitSize <= 0) ? 50 : limitSize;
        String orderField = String.isBlank(sortBy) ? 'LastModifiedDate' : sortBy;
        if (!SORTABLE_FIELDS.contains(orderField)) {
            orderField = 'LastModifiedDate';
        }
        String direction = (String.isBlank(sortDir) || sortDir.toLowerCase() != 'asc') ? 'DESC' : 'ASC';

        List<ListView> views = [
            SELECT Id, Name, SobjectType, IsSoqlCompatible, DeveloperName
            FROM ListView
            WHERE Id = :listViewId
            LIMIT 1
        ];
        if (views.isEmpty()) {
            throw new AuraHandledException('List view not found or not accessible.');
        }
        ListView viewRec = views[0];
        if (viewRec.SobjectType != 'PartnerFundRequest') {
            throw new AuraHandledException('Selected list view is not for PartnerFundRequest');
        }

        String soql = 'SELECT Id, Title, Core_MDF_Fund_Request_Status__c, Amount,Core_MDF_Start_Date_End_Date__c, Owner.Id, Owner.Name ' +
                      'FROM PartnerFundRequest ' +
                      'ORDER BY ' + orderField + ' ' + direction +
                      ' LIMIT :lim';

        return Database.query(soql);
    }

    
    public class OutcomeBasedActivitiesPage {
        @AuraEnabled public List<PartnerFundRequest> records { get; set; }
        @AuraEnabled public Integer totalRecords { get; set; }
        @AuraEnabled public Boolean hasNext { get; set; }
        @AuraEnabled public Boolean hasPrevious { get; set; }
        @AuraEnabled public String nextCursorValue { get; set; }
        @AuraEnabled public String nextCursorId { get; set; }
        @AuraEnabled public String previousCursorValue { get; set; }
        @AuraEnabled public String previousCursorId { get; set; }
    }

    // Main method for getting outcome-based activities
    @AuraEnabled(cacheable=true)
    public static OutcomeBasedActivitiesPage getOutcomeBasedActivities(String sortBy, String sortDirection, Integer pageSize, String pageDirection, String cursorValue, String cursorId, String statusFilter, String programFilter, String budgetFilter, String accountId, String searchKey) {
        try {
            String orderField = String.isBlank(sortBy) ? 'LastModifiedDate' : sortBy;
            if (!ACTIVITY_SORTABLE_FIELDS.contains(orderField)) {
                orderField = 'LastModifiedDate';
            }
            
            String direction = (String.isBlank(sortDirection) || sortDirection.toLowerCase() != 'asc') ? 'DESC' : 'ASC';
            String requestedPageDirection = String.isBlank(pageDirection) ? 'next' : pageDirection.toLowerCase();
            Integer normalizedPageSize = normalizeActivityPageSize(pageSize);
            Integer queryLimit = normalizedPageSize + 1;
            Boolean isReverseQuery = requestedPageDirection == 'previous' || requestedPageDirection == 'last';
            String queryDirection = isReverseQuery ? oppositeDirection(direction) : direction;
            String whereClause = buildOutcomeBasedWhereClause(statusFilter, programFilter, budgetFilter, accountId, searchKey);
            String cursorClause = buildActivityCursorClause(orderField, direction, requestedPageDirection, cursorValue, cursorId);
            String effectiveWhereClause = whereClause + cursorClause;
            Id cursorRecordId = String.isBlank(cursorId) ? null : Id.valueOf(cursorId);
            Object cursorFieldValue = coerceActivityCursorValue(orderField, cursorValue);
            
            String query = 'SELECT Id, Title, Core_MDF_Fund_Request_Status__c, Core_MDF_Maximum_Intel_Investment_amt__c, Core_MDF_Activity_Number__c, Core_MDF_Start_Date_End_Date__c, Core_MDF_Program__c, Core_MDF_Budget_Type_nm__c, ' +
                          'Owner.Name, LastModifiedDate, CreatedDate, ChannelPartnerId, ChannelPartner.Name ' +
                          'FROM PartnerFundRequest ' +
                          effectiveWhereClause + ' ' +
                          'ORDER BY ' + orderField + ' ' + queryDirection + ' NULLS LAST, Id ' + queryDirection + ' ' +
                          'LIMIT :queryLimit';
            
            List<PartnerFundRequest> queriedRecords = Database.query(query);
            Boolean hasExtraRecord = queriedRecords.size() > normalizedPageSize;
            if (hasExtraRecord) {
                queriedRecords.remove(normalizedPageSize);
            }
            if (isReverseQuery) {
                queriedRecords = reverseActivities(queriedRecords);
            }

            OutcomeBasedActivitiesPage result = new OutcomeBasedActivitiesPage();
            result.records = queriedRecords;
            result.totalRecords = Database.countQuery('SELECT COUNT() FROM PartnerFundRequest ' + whereClause);
            result.hasNext = requestedPageDirection == 'previous' ? true : (requestedPageDirection == 'last' ? false : hasExtraRecord);
            result.hasPrevious = requestedPageDirection == 'next' ? String.isNotBlank(cursorId) : hasExtraRecord;
            populateActivityCursors(result, queriedRecords, orderField);
            return result;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving campaigns: ' + e.getMessage());
        }
    }

    private static Integer normalizeActivityPageSize(Integer pageSize) {
        if (pageSize == null || pageSize <= 0) {
            return DEFAULT_ACTIVITY_PAGE_SIZE;
        }
        return Math.min(pageSize, MAX_ACTIVITY_PAGE_SIZE);
    }

    private static String buildOutcomeBasedWhereClause(String statusFilter, String programFilter, String budgetFilter, String accountId, String searchKey) {
        List<String> conditions = new List<String>{
            'Core_MDF_Is_Outcome_Based_Ind__c = true',
            'Core_MDF_Parent_Activity_Id__c = null',
            'Core_MDF_Activity_Level_nm__c != \'Sub Activity\''
        };
        if (String.isNotBlank(statusFilter)) {
            conditions.add('Core_MDF_Fund_Request_Status__c = \'' + String.escapeSingleQuotes(statusFilter.trim()) + '\'');
        }
        if (String.isNotBlank(programFilter)) {
            conditions.add('Core_MDF_Program__c = \'' + String.escapeSingleQuotes(programFilter.trim()) + '\'');
        }
        if (String.isNotBlank(budgetFilter)) {
            conditions.add('Core_MDF_Budget_Type_nm__c = \'' + String.escapeSingleQuotes(budgetFilter.trim()) + '\'');
        }
        if (String.isNotBlank(accountId)) {
            conditions.add('ChannelPartnerId = \'' + String.escapeSingleQuotes(String.valueOf(Id.valueOf(accountId))) + '\'');
        }
        if (String.isNotBlank(searchKey)) {
            String escapedSearchKey = String.escapeSingleQuotes(searchKey.trim());
            conditions.add('(Title LIKE \'%' + escapedSearchKey + '%\' OR Core_MDF_Activity_Number__c LIKE \'%' + escapedSearchKey + '%\')');
        }
        return 'WHERE ' + String.join(conditions, ' AND ');
    }

    private static String buildActivityCursorClause(String orderField, String direction, String pageDirection, String cursorValue, String cursorId) {
        if ((pageDirection != 'next' && pageDirection != 'previous') || String.isBlank(cursorId) || String.isBlank(cursorValue)) {
            return '';
        }
        String comparisonOperator = getActivityCursorComparison(direction, pageDirection);
        return ' AND (' + orderField + ' ' + comparisonOperator + ' :cursorFieldValue OR (' + orderField + ' = :cursorFieldValue AND Id ' + comparisonOperator + ' :cursorRecordId))';
    }

    private static String getActivityCursorComparison(String direction, String pageDirection) {
        Boolean ascending = direction == 'ASC';
        Boolean nextPage = pageDirection == 'next';
        return (ascending == nextPage) ? '>' : '<';
    }

    private static String oppositeDirection(String direction) {
        return direction == 'ASC' ? 'DESC' : 'ASC';
    }

    private static Object coerceActivityCursorValue(String orderField, String cursorValue) {
        if (String.isBlank(cursorValue)) {
            return null;
        }
        if (orderField == 'LastModifiedDate') {
            String normalizedDateTime = cursorValue.replace('T', ' ').replace('Z', '');
            if (normalizedDateTime.contains('.')) {
                normalizedDateTime = normalizedDateTime.substringBefore('.');
            }
            return Datetime.valueOfGmt(normalizedDateTime);
        }
        if (orderField == 'Core_MDF_Maximum_Intel_Investment_amt__c') {
            return Decimal.valueOf(cursorValue);
        }
        return cursorValue;
    }

    private static List<PartnerFundRequest> reverseActivities(List<PartnerFundRequest> records) {
        List<PartnerFundRequest> reversedRecords = new List<PartnerFundRequest>();
        for (Integer index = records.size() - 1; index >= 0; index--) {
            reversedRecords.add(records[index]);
        }
        return reversedRecords;
    }

    private static void populateActivityCursors(OutcomeBasedActivitiesPage result, List<PartnerFundRequest> records, String orderField) {
        if (records == null || records.isEmpty()) {
            return;
        }
        PartnerFundRequest firstRecord = records[0];
        PartnerFundRequest lastRecord = records[records.size() - 1];
        result.previousCursorValue = getActivityCursorValue(firstRecord, orderField);
        result.previousCursorId = firstRecord.Id;
        result.nextCursorValue = getActivityCursorValue(lastRecord, orderField);
        result.nextCursorId = lastRecord.Id;
    }

    private static String getActivityCursorValue(PartnerFundRequest record, String orderField) {
        Object fieldValue;
        if (orderField == 'ChannelPartner.Name') {
            fieldValue = record.ChannelPartner == null ? null : record.ChannelPartner.Name;
        } else {
            fieldValue = record.get(orderField);
        }
        return fieldValue == null ? null : String.valueOf(fieldValue);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<PicklistValue> getStatusPicklistValues() {
        try {
            List<PicklistValue> picklistValues = new List<PicklistValue>();
            
            Schema.DescribeFieldResult fieldResult = PartnerFundRequest.Core_MDF_Fund_Request_Status__c.getDescribe();
            List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
            
            for (Schema.PicklistEntry entry : picklistEntries) {
                if (entry.isActive()) {
                    picklistValues.add(new PicklistValue(entry.getLabel(), entry.getValue()));
                }
            }
            
            return picklistValues;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving status values: ' + e.getMessage());
        }
    }

    
    @AuraEnabled(cacheable=true)
    public static List<LookupResult> searchAccounts(String searchTerm) {
        try {
            List<LookupResult> results = new List<LookupResult>();
            
            if (String.isBlank(searchTerm) || searchTerm.length() < 2) {
                return results;
            }
            
            String searchKey = '%' + searchTerm + '%';
            
            // Query accounts that are associated with outcome-based campaigns
            List<Account> accounts = [
                SELECT Id, Name
                FROM Account 
                WHERE Name LIKE :searchKey
                AND Id IN (
                    SELECT ChannelPartnerId 
                    FROM PartnerFundRequest 
                    WHERE Core_MDF_Is_Outcome_Based_Ind__c = true 
                    AND Core_MDF_Parent_Activity_Id__c = null 
                    AND Core_MDF_Activity_Level_nm__c != 'Sub Activity'
                    AND ChannelPartnerId != null
                )
                ORDER BY Name
                LIMIT 50
            ];
            
            for (Account acc : accounts) {
                results.add(new LookupResult(acc.Id, acc.Name, 'Account'));
            }
            
            return results;
            
        } catch (Exception e) {
            throw new AuraHandledException('Error searching accounts: ' + e.getMessage());
        }
    }
    
    // Inner class for picklist values
    public class PicklistValue {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        
        public PicklistValue(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    // Inner class for lookup results
    public class LookupResult {
        @AuraEnabled
        public String id { get; set; }
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String subtitle { get; set; }
        
        public LookupResult(String id, String title, String subtitle) {
            this.id = id;
            this.title = title;
            this.subtitle = subtitle;
        }
    }
}