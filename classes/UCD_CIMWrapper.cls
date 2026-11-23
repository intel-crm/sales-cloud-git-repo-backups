public class UCD_CIMWrapper {

    public List<Organization> organization {get;set;}
    public String ErrorCd{get;set;}
    public String ErrorDetailsTxt{get;set;}
    public String ErrorDsc{get;set;}
    public String AsynchronousRequestId{get;set;}
    
    
    public class Organization{
        public Integer searchScore{get;set;}
        public Snapshot snapshot{get;set;}
        public SourceRecords sourceRecords{get;set;}
    }
    
    public class Snapshot{
        public BusinessOrganization BusinessOrganization{get;set;}
        public List<BusinessOrganizationNm> BusinessOrganizationNm{get;set;}
        public List<PhysicalAddress> PhysicalAddress{get;set;}
        public List<ElectronicAddress> ElectronicAddress{get;set;}
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationLegalAgreement{get;set;}
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationNAICS{get;set;}
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationRoleAssociation{get;set;}
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationSIC{get;set;}
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationThirdPartyTrustedSourceInfo{get;set;}
        public List<BusinessOrganizationThirdPartyWatchList> BusinessOrganizationThirdPartyWatchList{get;set;}
        public BusinessOrganizationTrustedReferenceProcessStatusAssociation BusinessOrganizationTrustedReferenceProcessStatusAssociation{get;set;}
        public BusinessOrganizationGoldStatusAssociation BusinessOrganizationGoldStatusAssociation{get;set;}
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationSalesGroup{get;set;}
        public String BusinessOrganizationAdditionalEntity{get;set;}
    }
    
    public class SourceRecords{
        public List<SourceRecord> sourceRecord{get;set;}
    }
    
    public class BusinessOrganization{
        public String BusinessOrganizationPartyId{get;set;}
        public String BusinessOrganizationClassificationCd{get;set;}
        public String AllIntelNoContactDtm{get;set;}
        public String DUNSNumber{get;set;}
        public String EffectiveStartDtm{get;set;}
        public String EffectiveEndDtm{get;set;}
    }
    
    public class BusinessOrganizationNm{
        public String BusinessOrganizationNm{get;set;}
        public String BusinessOrganizationNmTypeCd{get;set;}
        public String GoldenNameInd{get;set;}
        public String NonLatinInd{get;set;}
        public String LanguageCd{get;set;}
        public String EffectiveStartDtm{get;set;}
        public String EffectiveEndDtm{get;set;}
    }
    
    public class PhysicalAddress{
        public String PhysicalStreetAddressTxt{get;set;}
        public String PostOfficeOrLockBoxTxt{get;set;}
        public String CityNm{get;set;}
        public String CountrySubdivisionCd{get;set;}
        public String CountrySubdivisionNm{get;set;}
        public String CountryCd{get;set;}
        public String CountryNm{get;set;}
        public String PostalCd{get;set;}
        public String GoldenPhysicalAddressInd{get;set;}
        public String NonLatinDataInd{get;set;}
        public String LanguageCd{get;set;}
        public String EffectiveStartDtm{get;set;}
        public String EffectiveEndDtm{get;set;}
        public List<PhysicalAddressUsageLocationAssociation> PhysicalAddressUsageLocationAssociation{get;set;}
    }
    
    public class PhysicalAddressUsageLocationAssociation{
        public String PreferredMethodOfCommunicationInd{get;set;}
        public String ContactAllowedInd{get;set;}
        public String AddressUsageTypeCd{get;set;}
        public String AddressLocationTypeCd{get;set;}
        public String EffectiveStartDtm{get;set;}
        public String EffectiveEndDtm{get;set;}
    }
    
    public class ElectronicAddress{
        public String ElectronicAddressTypeCd{get;set;}
        public String ElectronicAddressTxt{get;set;}
        public String GoldenElectronicAddressInd{get;set;}
        public String EffectiveStartDtm{get;set;}
        public String EffectiveEndDtm{get;set;}
        public ElectronicAddressUsageLocationAssociation ElectronicAddressUsageLocationAssociation{get;set;}
    }
    
    public class ElectronicAddressUsageLocationAssociation{
        public String PreferredMethodOfCommunicationInd{get;set;}
        public String ContactAllowedInd{get;set;}
        public String AddressUsageTypeCd{get;set;}
        public String AddressLocationTypeCd{get;set;}
        public String EffectiveStartDtm{get;set;}
        public String EffectiveEndDtm{get;set;}
    }
    
    public class BusinessOrganizationThirdPartyWatchList{
        public String WatchListTypeCd{get;set;}
        public String WatchListTypeNm{get;set;}
        public String WatchListOrigCd{get;set;}
        public String WatchListAssignmentReasonKeyText{get;set;}
        public String BusinessReasonText{get;set;}
        public String EffectiveStartDtm{get;set;}
        public String EffectiveEndDtm{get;set;}
    }
    
    public class BusinessOrganizationTrustedReferenceProcessStatusAssociation{
        public String TrustedProcessStatusCd{get;set;}
        public String EffectiveStartDtm{get;set;}
        public String EffectiveEndDtm{get;set;}
    }
    
    public class BusinessOrganizationGoldStatusAssociation{
        public String GoldProcessStatusApprovalStatusCd{get;set;}
        public String EffectiveStartDtm{get;set;}
        public String EffectiveEndDtm{get;set;}
    }
    
    public class SourceRecord{
        public String SourceSystemCd{get;set;}
        public SourceBusinessOrganization SourceBusinessOrganization{get;set;}
        //public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationNm{get;set;}
        public list<SourceBusinessOrganizationNm> SourceBusinessOrganizationNm{get;set;}
        public List<PhysicalAddress> SourcePhysicalAddress{get;set;}
        //public List<BusinessOrganizationLegalAgreement> SourcePhysicalAddress{get;set;}
        public List<BusinessOrganizationLegalAgreement> SourceElectronicAddress{get;set;}
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationLegalAgreement{get;set;}
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationNAICS{get;set;}
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationRoleAssociation{get;set;}
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationSIC{get;set;}
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationThirdPartyTrustedSourceInfo{get;set;}
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationThirdPartyWatchList{get;set;}
        // Below code commented as response is a string
        //public SourceBusinessOrganizationEngagementDeduplicationGroupAssociation SourceBusinessOrganizationEngagementDeduplicationGroupAssociation{get;set;}
        public String SourceBusinessOrganizationEngagementDeduplicationGroupAssociation{get;set;}
        public String SourceBusinessOrganizationSalesGroup{get;set;}
        public String SourceBusinessOrganizationSourceSystemTestAttribute{get;set;}
        //public String SourceBusinessOrganizationStatus{get;set;}
        public SourceBusinessOrganizationStatus SourceBusinessOrganizationStatus{get;set;}
        public String SourceBusinessOrganizationAdditionalEntity{get;set;}
    }
    
    public class SourceBusinessOrganizationStatus{
        public string StatusTxt{get;set;}
    }
    
    public class SourceBusinessOrganization{
        public String BusinessOrganizationPartyId{get;set;}
        public String BusinessOrganizationClassificationCd{get;set;}
        public String AllIntelNoContactDtm{get;set;}
        public String DUNSNumber{get;set;}
        public String EffectiveStartDtm{get;set;}
        public String EffectiveEndDtm{get;set;}
    }
    
    public class SourceBusinessOrganizationEngagementDeduplicationGroupAssociation{
        public String EngagementDeduplicationGroupCd{get;set;}
        public String ActiveInd{get;set;}
    }
    
    public class BusinessOrganizationLegalAgreement{
        
    }
    // Added wrapper class for the SourceBusinessOrganizationNm
    public class SourceBusinessOrganizationNm{
        public string BusinessOrganizationNm{get;set;}
        public string BusinessOrganizationNmTypeCd{get;set;}
        public string GoldenNameInd{get;set;}
        public string NonLatinInd{get;set;}
        public string LanguageCd{get;set;}
        public string EffectiveStartDtm{get;set;}
        public string EffectiveEndDtm{get;set;}
        
    }
    
    
    
}