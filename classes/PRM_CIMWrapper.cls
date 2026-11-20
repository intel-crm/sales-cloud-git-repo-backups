/*********************************************************************************************************************
Apex Class Name  : PRM_CIMWrapper
Version       : 1.0
Created Date  : NOV 2018
Function      : Defines the structure of response from CIM

Modification Log :
* Developer                 Date                    Description
* --------------------------------------------------------------------------------------------------------------------
* Kushal Soni               11/29/2018              Defines the structure of response from CIM system
* Nishant Dhar               05/30/2018              Defines the structure of response from CIM system
*********************************************************************************************************************/

public class PRM_CIMWrapper{
    public List<Organization> organization;
    public String ErrorCd;
    public String ErrorDetailsTxt;
    public String ErrorDsc;
    public String AsynchronousRequestId;
    
    public PRM_CIMWrapper(){
        //Do nothing
    }
    
    public class Organization{
        public Integer searchScore;
        public Snapshot snapshot;
        public SourceRecords sourceRecords;
    }
    
    public class Snapshot{
        public BusinessOrganization BusinessOrganization;
        public List<BusinessOrganizationNm> BusinessOrganizationNm;
        public List<PhysicalAddress> PhysicalAddress;
        public List<ElectronicAddress> ElectronicAddress;
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationLegalAgreement;
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationNAICS;
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationRoleAssociation;
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationSIC;
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationThirdPartyTrustedSourceInfo;
        public List<BusinessOrganizationThirdPartyWatchList> BusinessOrganizationThirdPartyWatchList;
        public BusinessOrganizationTrustedReferenceProcessStatusAssociation BusinessOrganizationTrustedReferenceProcessStatusAssociation;
        public BusinessOrganizationGoldStatusAssociation BusinessOrganizationGoldStatusAssociation;
        public List<BusinessOrganizationLegalAgreement> BusinessOrganizationSalesGroup;
        public String BusinessOrganizationAdditionalEntity;
    }
    
    public class SourceRecords{
        public List<SourceRecord> sourceRecord;
    }
    
    public class BusinessOrganization{
        public String BusinessOrganizationPartyId;
        public String BusinessOrganizationClassificationCd;
        public String AllIntelNoContactDtm;
        public String DUNSNumber;
        public String EffectiveStartDtm;
        public String EffectiveEndDtm;
    }
    
    public class BusinessOrganizationNm{
        public String BusinessOrganizationNm;
        public String BusinessOrganizationNmTypeCd;
        public String GoldenNameInd;
        public String NonLatinInd;
        public String LanguageCd;
        public String EffectiveStartDtm;
        public String EffectiveEndDtm;
    }
    
    public class PhysicalAddress{
        public String PhysicalStreetAddressTxt;
        public String PostOfficeOrLockBoxTxt;
        public String CityNm;
        public String CountrySubdivisionCd;
        public String CountrySubdivisionNm;
        public String CountryCd;
        public String CountryNm;
        public String PostalCd;
        public String GoldenPhysicalAddressInd;
        public String NonLatinDataInd;
        public String LanguageCd;
        public String EffectiveStartDtm;
        public String EffectiveEndDtm;
        public List<PhysicalAddressUsageLocationAssociation> PhysicalAddressUsageLocationAssociation;
    }
    
    public class PhysicalAddressUsageLocationAssociation{
        public String PreferredMethodOfCommunicationInd;
        public String ContactAllowedInd;
        public String AddressUsageTypeCd;
        public String AddressLocationTypeCd;
        public String EffectiveStartDtm;
        public String EffectiveEndDtm;
    }
    
    public class ElectronicAddress{
        public String ElectronicAddressTypeCd;
        public String ElectronicAddressTxt;
        public String GoldenElectronicAddressInd;
        public String EffectiveStartDtm;
        public String EffectiveEndDtm;
        public ElectronicAddressUsageLocationAssociation ElectronicAddressUsageLocationAssociation;
    }
    
    public class ElectronicAddressUsageLocationAssociation{
        public String PreferredMethodOfCommunicationInd;
        public String ContactAllowedInd;
        public String AddressUsageTypeCd;
        public String AddressLocationTypeCd;
        public String EffectiveStartDtm;
        public String EffectiveEndDtm;
    }
    
    public class BusinessOrganizationThirdPartyWatchList{
        public String WatchListTypeCd;
        public String WatchListTypeNm;
        public String WatchListOrigCd;
        public String WatchListAssignmentReasonKeyText;
        public String BusinessReasonText;
        public String EffectiveStartDtm;
        public String EffectiveEndDtm;
    }
    
    public class BusinessOrganizationTrustedReferenceProcessStatusAssociation{
        public String TrustedProcessStatusCd;
        public String EffectiveStartDtm;
        public String EffectiveEndDtm;
    }
    
    public class BusinessOrganizationGoldStatusAssociation{
        public String GoldProcessStatusApprovalStatusCd;
        public String EffectiveStartDtm;
        public String EffectiveEndDtm;
    }
    
    public class SourceRecord{
        public String SourceSystemCd;
        public SourceBusinessOrganization SourceBusinessOrganization;
        //public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationNm;
        public list<SourceBusinessOrganizationNm> SourceBusinessOrganizationNm;
        public List<PhysicalAddress> SourcePhysicalAddress;
        //public List<BusinessOrganizationLegalAgreement> SourcePhysicalAddress;
        public List<BusinessOrganizationLegalAgreement> SourceElectronicAddress;
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationLegalAgreement;
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationNAICS;
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationRoleAssociation;
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationSIC;
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationThirdPartyTrustedSourceInfo;
        public List<BusinessOrganizationLegalAgreement> SourceBusinessOrganizationThirdPartyWatchList;
        // Below code commented as response is a string
        //public SourceBusinessOrganizationEngagementDeduplicationGroupAssociation SourceBusinessOrganizationEngagementDeduplicationGroupAssociation;
        public String SourceBusinessOrganizationEngagementDeduplicationGroupAssociation;
        public String SourceBusinessOrganizationSalesGroup;
        public String SourceBusinessOrganizationSourceSystemTestAttribute;
        //public String SourceBusinessOrganizationStatus;
        public SourceBusinessOrganizationStatus SourceBusinessOrganizationStatus;
        public String SourceBusinessOrganizationAdditionalEntity;
    }
    
    public class SourceBusinessOrganizationStatus{
        public string StatusTxt;
    }
    
    public class SourceBusinessOrganization{
        public String BusinessOrganizationPartyId;
        public String BusinessOrganizationClassificationCd;
        public String AllIntelNoContactDtm;
        public String DUNSNumber;
        public String EffectiveStartDtm;
        public String EffectiveEndDtm;
    }
    
    public class SourceBusinessOrganizationEngagementDeduplicationGroupAssociation{
        public String EngagementDeduplicationGroupCd;
        public String ActiveInd;
    }
    
    public class BusinessOrganizationLegalAgreement{
        
    }
    // Added wrapper class for the SourceBusinessOrganizationNm
    public class SourceBusinessOrganizationNm{
        public string BusinessOrganizationNm;
        public string BusinessOrganizationNmTypeCd;
        public string GoldenNameInd;
        public string NonLatinInd;
        public string LanguageCd;
        public string EffectiveStartDtm;
        public string EffectiveEndDtm;
        
    }
    
    
    
}