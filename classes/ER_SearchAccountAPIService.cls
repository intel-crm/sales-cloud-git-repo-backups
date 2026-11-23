public with sharing class ER_SearchAccountAPIService {
    
    private static final String BASE_ENDPOINT = 'callout:SalesCRM_Apigee/intel-products-customer/v1/intel-products-direct-customer-details';
    private static final Integer HTTP_TIMEOUT = 120000;
    
    @AuraEnabled(cacheable=false)
    public static Object searchBusinessPartners(String cmfGroupId, List<ER_SearchAccountModels.RequestBPModel> input) {
        Map<String, String> returnResult = new Map<String, String>{};
        String params = '';
        try {
            String filter = ER_AccountFilterBuilder.buildFilter(cmfGroupId, input);
            filter = filter.replaceAll('"', '%22').replaceAll(' ', '%20');
            String url = '$start_index=' + input[0].pageFirstRec + '&$filter=' + filter + '&$format=json';
            String endPoint = BASE_ENDPOINT + '?' + url + '&$count=1000';
            String strResponseCount;
            
            if (input[0].pageFirstRec == 0) {
                String countEndPoint = BASE_ENDPOINT + '/$count?$filter=' + filter + '&$format=json';
                HTTPResponse resCount = sendGetRequest(countEndPoint);
                params = 'ResponseStatus' + resCount.getStatusCode() + '-Filter' + filter;
                strResponseCount = resCount.getBody();
            }
            
            HTTPResponse res = sendGetRequest(endPoint);
            params = 'Status' + res.getStatusCode() + '-filter' + filter;
            String strResponse = res.getBody();
            
            Map<String, Object> resMap = (Map<String, Object>) JSON.deserializeUntyped(strResponse);
            String jsonSubset = JSON.serialize(resMap.get('elements'));
            List<ER_SearchAccountModels.DirectCustomerProfileData> dataElements = (List<ER_SearchAccountModels.DirectCustomerProfileData>) JSON.deserialize(jsonSubset, List<ER_SearchAccountModels.DirectCustomerProfileData>.class);
            
            Map<String, ER_SearchAccountModels.DirectCustomerProfileData> cmfDataMap = buildUniqueProfileMap(dataElements);
            flagExistingGroupAssociations(cmfDataMap);
            
            returnResult.put('RecordCount', strResponseCount);
            returnResult.put('Elements', JSON.serialize(cmfDataMap.values()));
            
            ER_ErrorUtility.createLogEntry('Search Business Partner Account Response ', null, 'Low', 'ER_SearchAccountAPIService', params.substring(0, Math.min(params.length(), 255)));
        } catch (Exception ex) {
            handleException('Search Business Partner Account Response ', ex, params);
        }
        return returnResult;
    }
    
    @AuraEnabled
    public static void saveBusinessPartnerAccounts(String bagId, List<ER_SearchAccountModels.BusinessPartnerDetailModel> inputData) {
        Map<String, ER_SearchAccountModels.BusinessPartnerDetailModel> accountDataMap = new Map<String, ER_SearchAccountModels.BusinessPartnerDetailModel>();
        for (ER_SearchAccountModels.BusinessPartnerDetailModel rec : inputData) {
            accountDataMap.put(rec.DirectCustomerProfileId, rec);
        }
        if (!accountDataMap.isEmpty()) {
            persistAccounts(bagId, accountDataMap);
        }
    }
    
    private static void persistAccounts(String bagId, Map<String, ER_SearchAccountModels.BusinessPartnerDetailModel> accountDataMap) {
        try {
            Id recordTypeId = Schema.sObjectType.Account.getRecordTypeInfosByName().get('Business Partner').getRecordTypeId();
            Map<String, Account> existingAccounts = getExistingAccountsByDirectId(accountDataMap.keySet());
            
            List<Account> accountsToUpsert = ER_AccountMapper.mapToAccounts(accountDataMap, existingAccounts, recordTypeId);
            
            if (!accountsToUpsert.isEmpty()) {
                List<Database.UpsertResult> upsertResults = Database.upsert(accountsToUpsert, false);
                logDmlErrors(upsertResults);
                
                for (Account acc : accountsToUpsert) {
                    existingAccounts.put(acc.Core_Direct_Account_Id__c, acc);
                }
                
                createAssociations(bagId, existingAccounts);
            }
        } catch (Exception ex) {
            handleException('Save Account Business Partner Data', ex, null);
        }
    }
    
    private static void createAssociations(String bagId, Map<String, Account> accountsByDirectId) {
        Set<Id> existingAssociatedAccountIds = new Set<Id>();
        for (ER_Account_Business_Partner__c assoc : [
            SELECT ER_Account__c FROM ER_Account_Business_Partner__c 
            WHERE ER_Customer_Master_File_Grouping__c = :bagId AND ER_Active__c = TRUE
        ]) {
            existingAssociatedAccountIds.add(assoc.ER_Account__c);
        }
        
        List<ER_Account_Business_Partner__c> newAssociations = new List<ER_Account_Business_Partner__c>();
        for (Account acc : accountsByDirectId.values()) {
            if (acc.Id != null && !existingAssociatedAccountIds.contains(acc.Id)) {
                newAssociations.add(new ER_Account_Business_Partner__c(
                    ER_Account__c = acc.Id,
                    ER_Customer_Master_File_Grouping__c = bagId,
                    ER_Active__c = true
                ));
            }
        }
        
        if (!newAssociations.isEmpty()) {
            insert newAssociations;
        }
    }
    
    private static Map<String, ER_SearchAccountModels.DirectCustomerProfileData> buildUniqueProfileMap(List<ER_SearchAccountModels.DirectCustomerProfileData> dataElements) {
        Map<String, ER_SearchAccountModels.DirectCustomerProfileData> cmfDataMap = new Map<String, ER_SearchAccountModels.DirectCustomerProfileData>();
        for (ER_SearchAccountModels.DirectCustomerProfileData rec : dataElements) {
            String unique = rec.DirectCustomerProfileId + '' + rec.SalesOrganizationCd + '' + rec.DistributionChannelCd + '' + rec.DistributionChannelNm + ' ' + rec.DirectCustomerRelationshipFunctionalRoleCd + ' ' + rec.DirectCustomerRelationshipFunctionalRoleNm;
            rec.disableButton = true;
            cmfDataMap.put(unique, rec);
        }
        return cmfDataMap;
    }
    
    private static void flagExistingGroupAssociations(Map<String, ER_SearchAccountModels.DirectCustomerProfileData> cmfDataMap) {
        for (ER_CMFGroupAssociation__c rec : [SELECT ER_Customer_Master_File__r.ER_CMFUnique__c FROM ER_CMFGroupAssociation__c WHERE ER_Customer_Master_File__r.ER_CMFUnique__c IN :cmfDataMap.keySet()]) {
            String cmfUnique = rec.ER_Customer_Master_File__r.ER_CMFUnique__c;
            if (String.isNotBlank(cmfUnique) && cmfDataMap.containsKey(cmfUnique)) {
                cmfDataMap.get(cmfUnique).disableButton = false;
            }
        }
    }
    
    private static Map<String, Account> getExistingAccountsByDirectId(Set<String> directAccountIds) {
        Map<String, Account> existingAccounts = new Map<String, Account>();
        for (Account acc : [SELECT Id, Core_Direct_Account_Id__c FROM Account WHERE RecordType.Name = 'Business Partner' AND Core_Direct_Account_Id__c IN :directAccountIds]) {
            existingAccounts.put(acc.Core_Direct_Account_Id__c, acc);
        }
        return existingAccounts;
    }
    
    private static void logDmlErrors(List<Database.UpsertResult> results) {
        for (Database.UpsertResult sr : results) {
            if (!sr.isSuccess()) {
                for (Database.Error err : sr.getErrors()) {
                    System.debug(err.getStatusCode() + ': ' + err.getMessage() + ' Fields: ' + err.getFields());
                }
            }
        }
    }
    
    private static void handleException(String context, Exception ex, String params) {
        ER_ErrorUtility.CustomException custEx = new ER_ErrorUtility.CustomException();
        custEx.Message = ex.getMessage();
        custEx.Cause = ex.getCause();
        custEx.StackTraceString = ex.getStackTraceString();
        custEx.LineNumber = ex.getLineNumber();
        custEx.TypeName = ex.getTypeName();
        ER_ErrorUtility.createLogEntry(context, custEx, 'High', 'ER_SearchAccountAPIService', params);
    }
    
    private static HTTPResponse sendGetRequest(String endpoint) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(HTTP_TIMEOUT);
        return new Http().send(req);
    }
    
}