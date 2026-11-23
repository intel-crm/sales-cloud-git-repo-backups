/**
 * @description Controller for API Documentation LWC Component
 * Fetches API configurations from custom settings and provides community URL
 */
public with sharing class Core_MDF_APIDocumentationController {
    /**
     * @description Wrapper class for API Documentation data
     */
    public class APIDocRecord {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public String category;
        @AuraEnabled
        public String operationName;
        @AuraEnabled
        public String apiMethod;
        @AuraEnabled
        public String apiEndpoint;
        @AuraEnabled
        public String version;
        @AuraEnabled
        public String statusCode;
        @AuraEnabled
        public String description;
        @AuraEnabled
        public Boolean isActive;
        @AuraEnabled
        public Boolean isDefault;
        @AuraEnabled
        public String eol;
        @AuraEnabled
        public String requestExample;
        @AuraEnabled
        public String responseExample;
        @AuraEnabled
        public Integer sortOrder;
        
        public APIDocRecord(Core_MDF_API_Documentation__c setting) {
            this.id = setting.Id;
            this.apiName = setting.API_Name__c;
            this.category = setting.Category__c;
            this.operationName = setting.Operation_Name__c;
            this.apiMethod = setting.API_Method__c;
            this.apiEndpoint = setting.API_Endpoint__c;
            this.version = setting.Version__c;
            this.statusCode = setting.Response_Status_Code__c;
            this.description = setting.Description__c;
            this.isActive = setting.Is_Active__c == null ? true : setting.Is_Active__c;
            this.isDefault = setting.Default__c == null ? false : setting.Default__c;
            this.eol = setting.EOL__c;
            this.requestExample = readStaticResourceText(
                setting.Request_Static_Resource_Name__c
            );
            this.responseExample = readStaticResourceText(
                setting.Response_Static_Resource_Name__c
            );
            this.sortOrder = setting.Sort_Order__c == null ? 0 : Integer.valueOf(setting.Sort_Order__c);
        }
    }

    private static String readStaticResourceText(String staticResourceName) {
        try {
            StaticResource resource = [
                SELECT Body
                FROM StaticResource
                WHERE Name = :staticResourceName
                LIMIT 1
            ];

            return resource.Body.toString();
        } catch (Exception e) {
            System.debug('Unable to read static resource ' + staticResourceName + ': ' + e.getMessage());
            return 'Unable to read static resource ';
        }
    }

    private class APISettingSorter implements Comparable {
        private Core_MDF_API_Documentation__c setting;

        APISettingSorter(Core_MDF_API_Documentation__c setting) {
            this.setting = setting;
        }

        public Integer compareTo(Object compareTo) {
            APISettingSorter other = (APISettingSorter)compareTo;
            Decimal thisSortOrder = setting.Sort_Order__c == null ? 999 : setting.Sort_Order__c;
            Decimal otherSortOrder = other.setting.Sort_Order__c == null ? 999 : other.setting.Sort_Order__c;

            if (thisSortOrder == otherSortOrder) {
                String thisName = setting.API_Name__c == null ? '' : setting.API_Name__c;
                String otherName = other.setting.API_Name__c == null ? '' : other.setting.API_Name__c;
                return thisName.compareTo(otherName);
            }

            return thisSortOrder < otherSortOrder ? -1 : 1;
        }
    }
    
    /**
     * @description Retrieves all API documentation records from custom settings
     * @return List of API documentation records sorted by Sort_Order__c
     */
    @AuraEnabled(cacheable=true)
    public static List<APIDocRecord> getAPIDocumentation() {
        try {
            Map<String, Core_MDF_API_Documentation__c> allSettings = Core_MDF_API_Documentation__c.getAll();
            List<APISettingSorter> sortedSettings = new List<APISettingSorter>();

            for (Core_MDF_API_Documentation__c setting : allSettings.values()) {
                if (setting.Is_Active__c == false) {
                    continue;
                }

                sortedSettings.add(new APISettingSorter(setting));
            }

            sortedSettings.sort();
            
            List<APIDocRecord> records = new List<APIDocRecord>();
            for (APISettingSorter sortedSetting : sortedSettings) {
                records.add(new APIDocRecord(sortedSetting.setting));
            }
            
            return records;
        } catch (Exception e) {
            System.debug('Error fetching API documentation: ' + e.getMessage());
            throw new AuraHandledException('Unable to fetch API documentation: ' + e.getMessage());
        }
    }
    
    /**
     * @description Gets the community URL dynamically based on org instance
     * @return Community URL in format: https://{instance}.sandbox.my.site.com/Partnercenter/API_Documentation
     */
    @AuraEnabled(cacheable=true)
    public static String getCommunityURL() {
        try {
            // Get the current org's instance URL
            String instanceUrl = URL.getOrgDomainUrl().getHost();
            
            // Extract instance name (e.g., intel--crmqa9 from intel--crmqa9.sandbox.my.salesforce.com)
            String[] parts = instanceUrl.split('\\.');
            String instanceName = parts[0]; // Get the instance part
            
            // Construct community URL
            // Community name: Partnercenter Unified Community
            // URL format: https://{instance}.sandbox.my.site.com/Partnercenter/API_Documentation
            String communityUrl;

            if (instanceUrl.contains('.sandbox.my.salesforce.com')) {
                communityUrl = 'https://' + instanceName + '.sandbox.my.site.com/Partnercenter/API_Documentation';
            } else {
                communityUrl = 'https://' + instanceName + '.intel.com/API_Documentation';
            }
            
            return communityUrl;
        } catch (Exception e) {
            System.debug('Error constructing community URL: ' + e.getMessage());
            return 'https://partnercenter.my.site.com/Partnercenter/API_Documentation'; // Fallback
        }
    }
}