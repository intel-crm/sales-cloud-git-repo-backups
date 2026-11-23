public with sharing class ER_SearchAccountModels {
    
    // Response wrapper mapping exactly to the Apigee JSON structure
    public class ApiResponse {
        // Must be named 'elements' to match the JSON response key automatically
        public List<DirectCustomerProfileData> elements { get; set; }
    }
    
    public class RequestBPModel {
        @AuraEnabled public String cmfId { get; set; }
        @AuraEnabled public String cmfName { get; set; }
        @AuraEnabled public String salesOrgCode { get; set; }
        @AuraEnabled public String salesDistiChannelCode { get; set; }
        @AuraEnabled public Integer pageFirstRec { get; set; }
    }
    
    public class DirectCustomerProfileData {
        @AuraEnabled public String DirectCustomerProfileId { get; set; }
        @AuraEnabled public String SalesOrganizationCd { get; set; }
        @AuraEnabled public String DistributionChannelCd { get; set; }
        @AuraEnabled public String DistributionChannelNm { get; set; }
        @AuraEnabled public String DirectCustomerRelationshipFunctionalRoleCd { get; set; }
        @AuraEnabled public String DirectCustomerRelationshipFunctionalRoleNm { get; set; }
        @AuraEnabled public String PhysicalStreetAddressTxt { get; set; }
        @AuraEnabled public String CityNm { get; set; }
        @AuraEnabled public String CountrySubDivisionNm { get; set; }
        @AuraEnabled public String CountryNm { get; set; }
        @AuraEnabled public String PostalCd { get; set; }
        @AuraEnabled public List<String> GroupName { get; set; }
        @AuraEnabled public String DirectCustomerProfileNm { get; set; }
        @AuraEnabled public String GeographyCd { get; set; }
        @AuraEnabled public String CentralDeleteInd { get; set; }
        @AuraEnabled public String DirectCustomerRoleCd { get; set; }
        @AuraEnabled public List<String> GroupLink { get; set; }
        @AuraEnabled public String CmfAssoc { get; set; }
        @AuraEnabled public String CmfAssocLink { get; set; }
        @AuraEnabled public String PartnerCustomerProfileId { get; set; }
        @AuraEnabled public Boolean disableButton { get; set; }
    }
    
    public class BusinessPartnerDetailModel {
        @AuraEnabled public String DirectCustomerProfileId { get; set; }
        @AuraEnabled public String DirectCustomerProfileTrimId { get; set; }
        @AuraEnabled public String DirectCustomerProfileNm { get; set; }
        @AuraEnabled public String NielsenId { get; set; }
        @AuraEnabled public String DistributionChannelCd { get; set; }
        @AuraEnabled public String DistributionChannelNm { get; set; }
        @AuraEnabled public String SalesOfficeCd { get; set; }
        @AuraEnabled public String SalesOfficeNm { get; set; }
        @AuraEnabled public String DivisionCd { get; set; }
        @AuraEnabled public String GeographyCd { get; set; }
        @AuraEnabled public String SalesGroupCd { get; set; }
        @AuraEnabled public String SalesGroupNm { get; set; }
        @AuraEnabled public String SalesOrganizationCd { get; set; }
        @AuraEnabled public String SalesOrganizationGroupCd { get; set; }
        @AuraEnabled public String DirectCustomerRevenueReportingClassificationCd { get; set; }
        @AuraEnabled public String DirectCustomerRevenueReportingClassificationNm { get; set; }
        @AuraEnabled public String CustomerSupplyAllocationClassificationCd { get; set; }
        @AuraEnabled public String CustomerSupployAllocationClassificationNm { get; set; }
        @AuraEnabled public String CustomerGroupTwoCd { get; set; }
        @AuraEnabled public String CustomerGroupThreeCd { get; set; }
        @AuraEnabled public String CustomerGroupFourCd { get; set; }
        @AuraEnabled public String CustomerGroupFiveCd { get; set; }
        @AuraEnabled public String PartnerCustomerProfileId { get; set; }
        @AuraEnabled public String DirectCustomerRelationshipFunctionalRoleCd { get; set; }
        @AuraEnabled public String DirectCustomerRelationshipFunctionalRoleNm { get; set; }
        @AuraEnabled public String DirectCustomerPriceGroupCd { get; set; }
        @AuraEnabled public String DirectCustomerRoleCd { get; set; }
        @AuraEnabled public String CentralDeleteInd { get; set; }
        @AuraEnabled public String EnglishPhysicalStreetAddressLine3 { get; set; }
        @AuraEnabled public String EnglishPhysicalStreetAddressLine4 { get; set; }
        @AuraEnabled public Object CustomerCentralOrderBlockCd { get; set; }
        @AuraEnabled public Object CustomerCentralBillingBlockCd { get; set; }
        @AuraEnabled public Object CustomerCentralDeliveryBlockCd { get; set; }
        @AuraEnabled public String DirectCustomerBusinessRoutingCd { get; set; }
        @AuraEnabled public String DirectCustomerBusinessRoutingNm { get; set; }
        @AuraEnabled public String IntelUltimateBusinessPartyId { get; set; }
        @AuraEnabled public Object SalesAreaOrderBlockCd { get; set; }
        @AuraEnabled public Object SalesAreaOrderBlockNm { get; set; }
        @AuraEnabled public Object SalesAreaBillingBlockCd { get; set; }
        @AuraEnabled public Object SalesAreaBillingBlockNm { get; set; }
        @AuraEnabled public Object SalesAreaDeliveryBlockCd { get; set; }
        @AuraEnabled public Object SalesAreaDeliveryBlockNm { get; set; }
        @AuraEnabled public String SalesAreaSalesBlockInd { get; set; }
        @AuraEnabled public String CountryCd { get; set; }
        @AuraEnabled public String CountryNm { get; set; }
        @AuraEnabled public String CityNm { get; set; }
        @AuraEnabled public String PostalCd { get; set; }
        @AuraEnabled public String CountrySubdivisionCd { get; set; }
        @AuraEnabled public String CountrySubdivisionNm { get; set; }
        @AuraEnabled public String PhysicalStreetAddressTxt { get; set; }
        @AuraEnabled public String PhysicalAddressCareOfNm { get; set; }
        @AuraEnabled public String PaymentTermCd { get; set; }
        @AuraEnabled public String CurrencyCd { get; set; }
        @AuraEnabled public String InternationalCommerceTermCd { get; set; }
        @AuraEnabled public String InternationalCommerceTermCd2 { get; set; }
        @AuraEnabled public String DirectCustomerCategoryCd { get; set; }
        @AuraEnabled public String DirectCustomerKeywordTxt { get; set; }
        @AuraEnabled public String CreateAgentId { get; set; }
        @AuraEnabled public String CreateDtm { get; set; }
        @AuraEnabled public String ChangeAgentId { get; set; }
        @AuraEnabled public String ChangeDtm { get; set; }
    }
}