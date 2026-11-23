public with sharing class ER_AccountMapper {
    
    private static final Map<String, String> ACCOUNT_TYPE_MAPPING = new Map<String, String>{
        'Sold-to Party' => 'Sold-to Party',
        'Ship-to Party' => 'Ship-to Party'
    };
    
    public static List<Account> mapToAccounts(Map<String, ER_SearchAccountModels.BusinessPartnerDetailModel> accountDataMap, Map<String, Account> existingAccounts, Id recordTypeId) {
        Map<String, String> countryCodeByCountryName = new Map<String, String>();
        List<Account> accounts = new List<Account>();
        
        for (String directAccountId : accountDataMap.keySet()) {
            ER_SearchAccountModels.BusinessPartnerDetailModel rec = accountDataMap.get(directAccountId);
            Boolean isExisting = existingAccounts.containsKey(directAccountId);
            Account acc = isExisting ? existingAccounts.get(directAccountId) : new Account();
            
            if (!isExisting) {
                acc.Core_Direct_Account_Id__c = rec.DirectCustomerProfileId;
                acc.RecordTypeId = recordTypeId;
            }
            
            populateAccountFields(acc, rec);
            countryCodeByCountryName = populateAddressFields(acc, rec, countryCodeByCountryName);
            accounts.add(acc);
        }
        
        return accounts;
    }
    
    private static void populateAccountFields(Account acc, ER_SearchAccountModels.BusinessPartnerDetailModel rec) {
        acc.Name = rec.DirectCustomerProfileNm;
        acc.Core_Direct_Account_Name_Txt__c = rec.DirectCustomerProfileNm;
        acc.Core_ER_Sales_Org_Name__c = rec.GeographyCd;
        acc.Core_Direct_Sales_Organization_Nm__c = rec.SalesOrganizationCd;
        acc.Core_ER_Sales_Disti_Chnl_Name__c = rec.DistributionChannelNm;
        acc.Core_Direct_Distributor_Channel_Nm__c = rec.DistributionChannelCd;
        acc.Core_ER_Direct_CustomerRelationship_Code__c = rec.DirectCustomerRelationshipFunctionalRoleCd;
        acc.Core_ER_Account_Group__c = rec.DirectCustomerRoleCd;
        acc.Core_ER_Sales_Area_Order_Block_Code__c = String.valueOf(rec.SalesAreaOrderBlockCd);
        acc.Core_ER_Sales_Area_Order_Block_Name__c = String.valueOf(rec.SalesAreaOrderBlockNm);
        
        if (ACCOUNT_TYPE_MAPPING.containsKey(rec.DirectCustomerRelationshipFunctionalRoleNm)) {
            acc.Core_Direct_Account_Type_Nm__c = ACCOUNT_TYPE_MAPPING.get(rec.DirectCustomerRelationshipFunctionalRoleNm);
        }
    }
    
    private static Map<String, String> populateAddressFields(Account acc, ER_SearchAccountModels.BusinessPartnerDetailModel rec, Map<String, String> countryCodeByCountryName) {
        if (String.isNotBlank(rec.CountryNm)) {
            if (countryCodeByCountryName.isEmpty()) {
                countryCodeByCountryName = UCD_ACM_Utils.getCountryCodeByName();
            }
            acc.BillingCountryCode = countryCodeByCountryName.get(rec.CountryNm);
        } else {
            acc.BillingCountryCode = null;
        }
        
        if (String.isNotBlank(rec.CountrySubdivisionNm)) {
            acc.BillingState = UCD_ACM_Utils.getStateCodeForStateName(rec.CountrySubdivisionNm, acc.BillingCountryCode);
        }
        
        acc.BillingCity = rec.CityNm;
        acc.BillingPostalCode = rec.PostalCd;
        
        return countryCodeByCountryName;
    }
}