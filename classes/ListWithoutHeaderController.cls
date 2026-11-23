public without sharing class ListWithoutHeaderController {
    
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
        'Title','Core_MDF_Fund_Request_Status__c','Amount','LastModifiedDate'
    };

    // Updated whitelist for outcome-based campaigns
    private static final Set<String> ACTIVITY_SORTABLE_FIELDS = new Set<String>{
        'Title','Core_MDF_Fund_Request_Status__c','Core_MDF_Maximum_Intel_Investment_amt__c','Core_MDF_Activity_Number__c','LastModifiedDate','ChannelPartner.Name'
    };

    
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

        String base = 'SELECT Id, Title, Core_MDF_Fund_Request_Status__c, Amount, Owner.Id, Owner.Name ' +
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

        String soql = 'SELECT Id, Title, Core_MDF_Fund_Request_Status__c, Amount, Owner.Id, Owner.Name ' +
                      'FROM PartnerFundRequest ' +
                      'ORDER BY ' + orderField + ' ' + direction +
                      ' LIMIT :lim';

        return Database.query(soql);
    }

    
    @AuraEnabled(cacheable=true)
    public static List<PartnerFundRequest> getOutcomeBasedActivities(String sortBy, String sortDirection) {
        try {
            // Validate sort parameters
            String orderField = String.isBlank(sortBy) ? 'LastModifiedDate' : sortBy;
            if (!ACTIVITY_SORTABLE_FIELDS.contains(orderField)) {
                orderField = 'LastModifiedDate';
            }
            
            String direction = (String.isBlank(sortDirection) || sortDirection.toLowerCase() != 'asc') ? 'DESC' : 'ASC';
            
            // Updated query with additional conditions
            String query = 'SELECT Id, Title, Core_MDF_Fund_Request_Status__c, Core_MDF_Maximum_Intel_Investment_amt__c, Core_MDF_Activity_Number__c, ' +
                          'Owner.Name, LastModifiedDate, CreatedDate, ChannelPartnerId, ChannelPartner.Name ' +
                          'FROM PartnerFundRequest ' +
                          'WHERE Core_MDF_Is_Outcome_Based_Ind__c = true ' +
                          'AND Core_MDF_Parent_Activity_Id__c = null ' +
                          'AND Core_MDF_Activity_Level_nm__c != \'Sub Activity\' ' +
                          'ORDER BY ' + orderField + ' ' + direction + ' ' +
                          'LIMIT 1000';
            
            return Database.query(query);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving campaigns: ' + e.getMessage());
        }
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