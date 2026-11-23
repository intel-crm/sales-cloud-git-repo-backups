public with sharing class ER_AccountFilterBuilder {
    
    @TestVisible
    private static final String BASE_FILTER = 'COALESCE(\"SalesAreaOrderBlockCd\",\'\')+not+in+(\'99\',\'01\')';
    
    public static String buildFilter(String cmfGroupId, List<ER_SearchAccountModels.RequestBPModel> cmfs) {
        String filter = BASE_FILTER;
        filter = appendFieldFilters(filter, cmfs);
        filter = appendPartnerFilter(filter);
        filter = appendRoleFilter(filter, cmfGroupId);
        return filter;
    }
    
    private static String appendFieldFilters(String filter, List<ER_SearchAccountModels.RequestBPModel> cmfs) {
        for (ER_SearchAccountModels.RequestBPModel cmf : cmfs) {
            List<String> fieldFilters = new List<String>();
            addFieldFilter(fieldFilters, 'DirectCustomerProfileId', cmf.cmfId);
            addFieldFilter(fieldFilters, 'DirectCustomerProfileNm', cmf.cmfName);
            addFieldFilter(fieldFilters, 'SalesOrganizationCd', cmf.salesOrgCode);
            addFieldFilter(fieldFilters, 'DistributionChannelCd', cmf.salesDistiChannelCode);
            
            for (String f : fieldFilters) {
                filter = String.isNotBlank(filter) ? filter + 'AND' + f : f;
            }
        }
        return filter;
    }
    
    private static void addFieldFilter(List<String> filters, String fieldName, String value) {
        if (String.isNotBlank(value)) {
            filters.add('\"' + fieldName + '"=\'' + String.escapeSingleQuotes(value) + '\'');
        }
    }
    
    private static String appendPartnerFilter(String filter) {
        String partnerFilter = '"DirectCustomerProfileId"="PartnerCustomerProfileId"';
        return String.isNotBlank(filter) ? filter + 'AND' + partnerFilter : partnerFilter;
    }
    
    private static String appendRoleFilter(String filter, String cmfGroupId) {
        Boolean isODM = hasODMAssociation(cmfGroupId);
        String roleCd = isODM ? 'WE' : 'AG';
        String roleFilter = '"DirectCustomerRelationshipFunctionalRoleCd"=\'' + roleCd + '\'';
        return String.isNotBlank(filter) ? filter + 'AND' + roleFilter : roleFilter;
    }
    
    private static Boolean hasODMAssociation(String cmfGroupId) {
        List<ER_ContactGroupAssociation__c> accWithODM = [
            SELECT Id FROM ER_ContactGroupAssociation__c 
            WHERE ER_Customer_Master_File_Group__r.Id = :cmfGroupId 
            AND ER_Contact__r.Account.Core_IsODM__c = true 
            AND ER_Active__c = true 
            LIMIT 1
        ];
        return !accWithODM.isEmpty();
    }
}