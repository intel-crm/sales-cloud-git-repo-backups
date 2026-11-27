public with sharing class PRM_EndCustomerAccountSearchController {
    
    private static final Integer MAX_RESULTS = 10;
    
    //private static final String DESIGN_REGISTRATION_OBJECT = 'Core_Design_Registration__c';
    
    private static final String PARTNER_DEAL_OBJECT = 'PRM_Partner_Deal_Opportunity__c';
    
    private static final String MASTERED_ACCOUNT_RECORD_TYPE =
        'Mastered_Account';
    
    private static final String END_CUSTOMER_DEAL_RECORD_TYPE =
        'End_Customer_Deal_Account';
    
    private static final String REQUESTED_ACCOUNT_RECORD_TYPE =
        'Requested_Account';
    
    public class AccountSearchResult {
        @AuraEnabled public Id accountId;
        @AuraEnabled public String accountName;
        @AuraEnabled public String billingCountry;
        @AuraEnabled public String website;
        @AuraEnabled public String ownerName;
        @AuraEnabled public String recordTypeName;
        @AuraEnabled public String recordTypeDeveloperName;
    }

    @AuraEnabled(cacheable=true)
    public static List<AccountSearchResult> searchAccounts(
        String customerName,String customerCountry,String customerWebsite,String sourceObjectApiName) {
            
        List<AccountSearchResult> results = new List<AccountSearchResult>();
        System.debug(LoggingLevel.INFO, '========== ACCOUNT SEARCH START ==========');
        System.debug(LoggingLevel.INFO, 'Customer Name: ' + customerName);
        System.debug(LoggingLevel.INFO, 'Customer Country: ' + customerCountry);
        System.debug(LoggingLevel.INFO, 'Customer Website: ' + customerWebsite);
        System.debug(LoggingLevel.INFO, 'Source Object: ' + sourceObjectApiName);
        
        // STEP 1: VALIDATE INPUTS
        if (String.isBlank(customerName) || String.isBlank(sourceObjectApiName)) {
            System.debug(LoggingLevel.WARN, 'Search stopped: Name or Source Object is blank.');
            return results;
        }
        
        System.debug(LoggingLevel.INFO, 'Customer Name validation successful.');
        
        // STEP 2: DETERMINE ALLOWED RECORD TYPES
        Set<String> allowedRecordTypes = new Set<String>{
            MASTERED_ACCOUNT_RECORD_TYPE,
                END_CUSTOMER_DEAL_RECORD_TYPE,
                REQUESTED_ACCOUNT_RECORD_TYPE
                };
                    
                    System.debug(LoggingLevel.INFO, 'Allowed Record Types: ' + allowedRecordTypes);
        
        // STEP 3: PREPARE SEARCH FILTERS
        String nameFilter = '%' + customerName.trim() + '%';
        String countryFilter = getCountryCode(customerCountry);
        String websiteFilter = String.isBlank(customerWebsite)
            ? null
            : customerWebsite.trim();
        
        System.debug(LoggingLevel.INFO, 'Name Filter: ' + nameFilter);
        System.debug(LoggingLevel.INFO, 'Country Filter: ' + countryFilter);
        System.debug(LoggingLevel.INFO, 'Website Filter: ' + websiteFilter);
        
        String selectQuery =
            'SELECT Id, Name, BillingCountry, BillingAddress, Website, ' +
            'Core_User_Defined_Website__c, Core_IPA_Partner_Role__c, ' +
            'Core_Intel_Partner_Alliance_PartnerGroup__c, Owner.Name, ' +
            'RecordType.Name, RecordType.DeveloperName FROM Account ';
        
        String baseCondition =
            ' WHERE RecordType.DeveloperName IN :allowedRecordTypes ';
        
        String orderLimit = ' ORDER BY Name LIMIT :MAX_RESULTS';
        
        // STEP 4: BUILD AND CONDITIONS
        String andCondition = ' AND Name LIKE :nameFilter ';
        
        if (String.isNotBlank(countryFilter)) {
            andCondition += ' AND BillingCountry = :countryFilter ';
            System.debug(LoggingLevel.INFO, 'Country condition added.');
        } else {
            System.debug(LoggingLevel.INFO, 'Country condition skipped because country is blank.');
        }
        
        if (String.isNotBlank(websiteFilter)) {
            andCondition +=
                ' AND (Website = :websiteFilter OR Core_User_Defined_Website__c = :websiteFilter) ';
            System.debug(LoggingLevel.INFO, 'Website condition added.');
        } else {
            System.debug(LoggingLevel.INFO, 'Website condition skipped because website is blank.');
        }
        
        Map<String, Object> queryBinds = new Map<String, Object>{
            'allowedRecordTypes' => allowedRecordTypes,
                'nameFilter' => nameFilter,
                'countryFilter' => countryFilter,
                'websiteFilter' => websiteFilter,
                'MAX_RESULTS' => MAX_RESULTS
                };
                    
                    System.debug(LoggingLevel.INFO, 'Query Bind Parameters: ' + queryBinds);
        
        // STEP 5: FIRST SEARCH - NAME AND COUNTRY AND WEBSITE
        String andQuery = selectQuery + baseCondition + andCondition + orderLimit;
        
        System.debug(LoggingLevel.INFO, 'AND SEARCH QUERY: ' + andQuery);
        
        List<Account> candidateAccounts = Database.queryWithBinds(
            andQuery,
            queryBinds,
            AccessLevel.USER_MODE
        );
        
        System.debug(LoggingLevel.INFO, 'AND SEARCH RESULT COUNT: ' + candidateAccounts.size());
        
        // STEP 6: SECOND SEARCH - NAME AND (COUNTRY OR WEBSITE)
        if (candidateAccounts.isEmpty()) {
            
            System.debug(LoggingLevel.INFO, 'AND returned zero records. Starting OR search.');
            
            String orCondition = ' AND (';
            
            if (String.isNotBlank(countryFilter) && String.isNotBlank(websiteFilter)) {
                
                orCondition += ' BillingCountry = :countryFilter ';
                orCondition +=
                    ' OR (Website = :websiteFilter OR Core_User_Defined_Website__c = :websiteFilter) ';
                
            } else if (String.isNotBlank(countryFilter)) {
                
                orCondition += ' BillingCountry = :countryFilter ';
                
            } else if (String.isNotBlank(websiteFilter)) {
                orCondition +=' (Website = :websiteFilter OR Core_User_Defined_Website__c = :websiteFilter) ';
                
            } else {
                orCondition += ' Name LIKE :nameFilter ';
            }
            
            orCondition += ') ';
            
            String orQuery = selectQuery + baseCondition +
                ' AND Name LIKE :nameFilter ' +
                orCondition + orderLimit;
            
            System.debug(LoggingLevel.INFO, 'OR SEARCH QUERY: ' + orQuery);
            
            candidateAccounts = Database.queryWithBinds(
                orQuery,
                queryBinds,
                AccessLevel.USER_MODE
            );
            
            System.debug(LoggingLevel.INFO, 'OR SEARCH RESULT COUNT: ' + candidateAccounts.size());
            
            // STEP 7: THIRD SEARCH - NAME ONLY IF OR RETURNS FEWER THAN MAX_RESULTS
            if (candidateAccounts.size() < MAX_RESULTS) {
                
                System.debug(
                    LoggingLevel.INFO,
                    'OR returned fewer than MAX_RESULTS. Starting Name-only search.'
                );
                
                String nameOnlyQuery = selectQuery + baseCondition +
                    ' AND Name LIKE :nameFilter ' + orderLimit;
                
                System.debug(LoggingLevel.INFO, 'NAME-ONLY SEARCH QUERY: ' + nameOnlyQuery);
                
                List<Account> nameOnlyAccounts = Database.queryWithBinds(
                    nameOnlyQuery,
                    queryBinds,
                    AccessLevel.USER_MODE
                );
                
                // Merge results without duplicates.
                // Preserve OR-search results as the highest priority.
                Map<Id, Account> mergedAccounts = new Map<Id, Account>();
                
                for (Account acc : candidateAccounts) {mergedAccounts.put(acc.Id, acc);
                                                      }
                
                for (Account acc : nameOnlyAccounts) {
                    
                    if (mergedAccounts.size() >= MAX_RESULTS) {break;
                                                              }
                    
                    if (!mergedAccounts.containsKey(acc.Id)) {
                        mergedAccounts.put(acc.Id, acc);
                    }
                }
                
                candidateAccounts = new List<Account>(mergedAccounts.values());
                
                System.debug(
                    LoggingLevel.INFO,
                    'FINAL MERGED RESULT COUNT: ' + candidateAccounts.size()
                );
            }
            
        } else {
            
            System.debug(LoggingLevel.INFO, 'AND search successful. OR and Name-only searches skipped.');
        }
        
        System.debug(LoggingLevel.INFO, 'FINAL CANDIDATE COUNT: ' + candidateAccounts.size());
        
        // STEP 8: MAP RESULTS
        for (Account accountRecord : candidateAccounts) {
            
            AccountSearchResult row = new AccountSearchResult();
            
            row.accountId = accountRecord.Id;
            row.accountName = accountRecord.Name;
            row.billingCountry = accountRecord.BillingCountry;
            row.website = accountRecord.Website;
            row.ownerName = accountRecord.Owner != null? accountRecord.Owner.Name: null;
            row.recordTypeName = accountRecord.RecordType.Name;
            row.recordTypeDeveloperName = accountRecord.RecordType.DeveloperName;
            
            System.debug(LoggingLevel.INFO, 'Matched Account: ' + accountRecord.Name);
            
            results.add(row);
        }
        
        System.debug(LoggingLevel.INFO, '========== ACCOUNT SEARCH END ==========');
        
        return results;
    }
    
    
    // CONVERT COUNTRY NAME TO COUNTRY CODE
    private static String getCountryCode(String countryName) {
        if (String.isBlank(countryName)) {
            return null;
        }
        String inputCountry = countryName.trim();
        
        for (Schema.PicklistEntry entry : Account.BillingCountryCode.getDescribe().getPicklistValues()) {
            if (entry.getLabel().equalsIgnoreCase(inputCountry) || entry.getValue().equalsIgnoreCase(inputCountry)) {
                return entry.getValue();
            }
        }
        return inputCountry;
    }
    

@AuraEnabled
public static ID insertAccount(String accountName, String country) {

    System.debug(LoggingLevel.INFO, '===== START insertAccount =====');
    System.debug(LoggingLevel.DEBUG, 'Input accountName: ' + accountName);
    System.debug(LoggingLevel.DEBUG, 'Input country: ' + country);

    try {

        // Validate Account Name
        if (String.isBlank(accountName)) {
            System.debug(LoggingLevel.ERROR, 'Validation Failed: Account Name is blank');

            throw new AuraHandledException(
                'End Customer Name is required.'
            );
        }

        System.debug(LoggingLevel.DEBUG, 'Account Name validation passed');

        // Validate Country
        if (String.isBlank(country)) {
            System.debug(LoggingLevel.ERROR, 'Validation Failed: Country is blank');

            throw new AuraHandledException(
                'Country is required.'
            );
        }

        System.debug(LoggingLevel.DEBUG, 'Country validation passed');

        // Initialize request model
        UCD_BizOrgRequestModel bizModel =
            new UCD_BizOrgRequestModel();

        UCD_BizOrgRequestModel.AccountDetail accountRequest =
            new UCD_BizOrgRequestModel.AccountDetail();

        accountRequest.Name = accountName.trim();

        System.debug(LoggingLevel.DEBUG,
            'Account Name assigned: ' + accountRequest.Name);

        accountRequest.CustomerAggregationTypeCode = 'UNFD_CTRY_CUST';
        accountRequest.CustomerProcessEngagmentCode = 'DIR_PRC_EXCPT';

        System.debug(LoggingLevel.DEBUG,
            'Customer Aggregation Type: ' + accountRequest.CustomerAggregationTypeCode);

        System.debug(LoggingLevel.DEBUG,
            'Customer Process Engagement Code: ' + accountRequest.CustomerProcessEngagmentCode);

        // Process Country
        if (String.isNotBlank(country)) {

            System.debug(LoggingLevel.INFO, 'Inside country processing block');

            UCD_BizOrgRequestModel.AccountAddresses address =
                new UCD_BizOrgRequestModel.AccountAddresses();

            address.TypeCode = 'Billing';

            String trimmedCountry = country.trim();

            System.debug(LoggingLevel.DEBUG,
                'Trimmed Country: ' + trimmedCountry);

            if (trimmedCountry.length() == 3) {

                address.CountryCode = trimmedCountry;

                System.debug(LoggingLevel.INFO,
                    'Country identified as 3-character Country Code: ' + address.CountryCode);

            } else {

                address.CountryName = trimmedCountry;

                System.debug(LoggingLevel.INFO,
                    'Country identified as Country Name: ' + address.CountryName);
            }

            accountRequest.Addresses =
                new List<UCD_BizOrgRequestModel.AccountAddresses>{
                    address
                };

            System.debug(LoggingLevel.DEBUG,
                'Billing Address added to Account Request');
        }

        // Prepare final request
        bizModel.AccountRequests =
            new List<UCD_BizOrgRequestModel.AccountDetail>{
                accountRequest
            };

        System.debug(LoggingLevel.INFO,
            'Account Request prepared successfully');

        System.debug(LoggingLevel.DEBUG,
            'Request Account Name: ' + accountRequest.Name);

        System.debug(LoggingLevel.DEBUG,
            'Request Addresses: ' + JSON.serialize(accountRequest.Addresses));

        // Call Business Organization Service
        System.debug(LoggingLevel.INFO,
            'Calling createBusinessOrganizationRequest...');

        List<UCD_BizOrgRequestModel.BusinessOrganizationResponse> responses =
            UCD_BizOrgRequestController.createBusinessOrganizationRequest(bizModel);

        System.debug(LoggingLevel.INFO,
            'Service call completed');

        System.debug(LoggingLevel.DEBUG,
            'Service Response: ' + JSON.serialize(responses));

        // Process Response
        if (responses != null) {

            System.debug(LoggingLevel.INFO,
                'Response count: ' + responses.size());

            for (
                UCD_BizOrgRequestModel.BusinessOrganizationResponse response
                : responses
            ) {

                System.debug(LoggingLevel.DEBUG,
                    'Response Status: ' + response.Status);

                System.debug(LoggingLevel.DEBUG,
                    'Response Error Message: ' + response.Errormessage);

                System.debug(LoggingLevel.DEBUG,
                    'Response Data: ' + JSON.serialize(response.Data));

                if (
                    response.Status == 'Success' &&
                    response.Data != null &&
                    response.Data.AccountId != null
                ) {

                    System.debug(LoggingLevel.INFO,
                        'Account Created Successfully');

                    System.debug(LoggingLevel.INFO,
                        'Created Account ID: ' + response.Data.AccountId);

                    System.debug(LoggingLevel.INFO,
                        '===== END insertAccount - SUCCESS =====');

                    return response.Data.AccountId;
                }
            }

        } else {

            System.debug(LoggingLevel.ERROR,
                'Service returned NULL response');
        }

        // Handle service errors
        String errorMessage =
            'The Account request did not return a successfully created Account ID.';

        if (responses != null) {

            for (
                UCD_BizOrgRequestModel.BusinessOrganizationResponse response
                : responses
            ) {

                if (String.isNotBlank(response.Errormessage)) {

                    errorMessage = response.Errormessage;

                    System.debug(LoggingLevel.ERROR,
                        'Service Error: ' + errorMessage);

                    break;
                }
            }
        }

        System.debug(LoggingLevel.ERROR,
            'Account Creation Failed: ' + errorMessage);

        System.debug(LoggingLevel.INFO,
            '===== END insertAccount - FAILURE =====');

        throw new AuraHandledException(errorMessage);

    } catch (Exception e) {

        System.debug(LoggingLevel.ERROR,
            'Exception Type: ' + e.getTypeName());

        System.debug(LoggingLevel.ERROR,
            'Exception Message: ' + e.getMessage());

        System.debug(LoggingLevel.ERROR,
            'Exception Line Number: ' + e.getLineNumber());

        System.debug(LoggingLevel.ERROR,
            'Exception Stack Trace: ' + e.getStackTraceString());

        System.debug(LoggingLevel.INFO,
            '===== END insertAccount - EXCEPTION =====');

        throw new AuraHandledException(e.getMessage());
    }
}

    
}