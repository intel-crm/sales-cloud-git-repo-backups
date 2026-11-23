public without sharing class Core_ConstantUtility{
    
    //.equalsIgnoreCase(Core_ConstantUtility.SR_SYSTEMCD)
    public static final String HDR = 'Header';
    public static final String HDR_MSGTYPE = 'MsgType';
    public static final String HDR_MSGTYPE_UPSERT = 'UPSERT';
    public static final String HDR_MSGTYPE_DELETE = 'DELETE';
    public static final String HDR_MSGID = 'MsgId';
    public static final String HDR_EVTTYPE = 'EventType';
    public static final String HDR_EVTTYPE_CORE = 'CORE';
    public static final String HDR_EVTTYPE_NONCORE = 'NONCORE';
    public static final String HDR_EVTTYPE_MERGE = 'MERGE';
    public static final String HDR_EVTTYPE_BRNDNOCNTC = 'BRNDNOCNTC';
    public static final String HDR_EVTTYPE_MERGEBRNDNOCNTC = 'MERGEBRNDNOCNTC';
    public static final String HDR_EVTTYPE_MDR = 'MDR';
    
    public static final String SNP = 'Snapshot';    
    public static final String SNP_BUS_ORG = 'BusinessOrganization';
    public static final String SNP_PHY_ADDRESS = 'PhysicalAddress';
    public static final String SNP_BUS_ORG_NM = 'BusinessOrganizationNm';
    public static final String SNP_ELEC_ADDRESS = 'ElectronicAddress';    
    public static final String SNP_BUS_ORG_ID = 'BusinessOrganizationPartyId';
    public static final String SNP_BUS_ORG_CLASSCD = 'BusinessOrganizationClassificationCd';
    public static final String SNP_GOLDEN_NAME_IND = 'GoldenNameInd';
    public static final String SNP_NON_LATIN_IND = 'NonLatinInd';    
    //public static final String SNP_BUS_ORG_NM_CHILD = 'BusinessOrganizationNm';
    public static final String SNP_STREET = 'PhysicalStreetAddressTxt';
    public static final String SNP_CITY = 'CityNm';
    public static final String SNP_STATE_NM = 'CountrySubdivisionNm';
    public static final String SNP_STATE = 'CountrySubdivisionCd';
    public static final String SNP_COUNTRY_NM = 'CountryNm';
    public static final String SNP_COUNTRY = 'CountryCd';
    public static final String SNP_POSTAL = 'PostalCd';
    public static final String SNP_GOLDEN_PHY_ADR_IND = 'GoldenPhysicalAddressInd';
    public static final String SNP_NON_LATIN_DATA_IND = 'NonLatinDataInd';
    public static final String SNP_ELEC_ADR_CD = 'ElectronicAddressTypeCd';
    public static final String SNP_ELEC_ADR_TXT = 'ElectronicAddressTxt';
    public static final String SNP_ELEC_ADR_FAX = 'FAX';
    public static final String SNP_ELEC_ADR_PHONE = 'PHONE';
    public static final String SNP_ELEC_ADR_URL = 'URL';
    public static final String SNP_BUS_ORG_THIRDPARTY_WATCHLIST = 'BusinessOrganizationThirdPartyWatchList';
    public static final String SNP_BUS_ORG_GOLD_STATUS_ASSOC = 'BusinessOrganizationGoldStatusAssociation';
    public static final String SNP_WATCHLIST_TYPE_CD = 'WatchListTypeCd';
    public static final String SNP_WATCHLIST_TYPE_NAME = 'WatchListTypeNm';
    public static final String SNP_GOLDSTATUS_APPROVAL_CD = 'GoldProcessStatusApprovalStatusCd';
    public static final String SNP_MAG = 'MAG';
    public static final String SNP_EC = 'EC';
    public static final String SNP_ECB = 'ECB';
    public static final String SNP_DUNSNUMBER = 'DUNSNumber';
    
    public static final String SRS = 'SourceRecords';
    public static final String SR = 'SourceRecord';
    public static final String SR_SYSTEMCD = 'SourceSystemCd';
    public static final String SR_ERPM = 'ERPM';
    public static final String SR_SLSCLD = 'SLSCLD';
    public static final String SR_BVD = 'BVD';// Added by Monisha Pandurangan
    public static final String SR_CIMHUB = 'CIMHUB-LATIN';
    public static final String SR_BUS_ORG = 'SourceBusinessOrganization';
    public static final String SR_BUS_ORG_NM = 'SourceBusinessOrganizationNm';
    public static final String SR_PHY_ADDRESS = 'SourcePhysicalAddress';
    public static final String SR_BUS_ORG_ID = 'BusinessOrganizationPartyId';
    public static final String SR_NON_LATIN_IND = 'NonLatinInd';
    public static final String SR_BUS_ORG_NM_CHILD = 'BusinessOrganizationNm';
    public static final String SR_BUS_ORG_NM_TYPECD = 'BusinessOrganizationNmTypeCd';
    public static final String SR_BUS_ORG_DEDUPGRP_ASSOC = 'SourceBusinessOrganizationEngagementDeduplicationGroupAssociation';
    public static final String SR_ENGAGEDEDUP_CD = 'EngagementDeduplicationGroupCd';
    public static final String SR_ACTIVE_IND = 'ActiveInd';
    public static final String SR_DEDUP_ITP = 'DEDUPGPITP';
    public static final String SR_DEDUP_B2B = 'DEDUPB2B';
    public static final String SLSCLD_TAG = '<'+SR_SYSTEMCD+'>'+SR_SLSCLD+'</'+SR_SYSTEMCD+'>';
    public static final String ERPM_TAG = '<'+SR_SYSTEMCD+'>'+SR_ERPM+'</'+SR_SYSTEMCD+'>';
    public static final String SR_INDUSCLASSPRIORITY_CD = 'IndustrialClassificationPriorityCd';
    public static final String SR_STDINDUSCLASSCD = 'StandardIndustrialClassificationCd';
    public static final String SR_STDINDUSCLASS_DESC = 'StandardIndustrialClassificationDesc';
    public static final String SR_BUSORG_SIC = 'SourceBusinessOrganizationSIC';
  
    public static final String MERGEBO = 'MergeBusinessOrganization';
    public static final String SURVIVORID = 'SurvivorBusinessOrganizationPartyId';
    public static final String NONSURVIVORID = 'NonSurvivorBusinessOrganizationPartyId';
    
    public static final String ALL_TAG = 'All';
    
    public static final String Y_INDICATOR = 'Y';
    public static final String N_INDICATOR = 'N';
   
}