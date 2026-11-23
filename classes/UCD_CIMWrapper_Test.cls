@isTest
private class UCD_CIMWrapper_Test {
    static testMethod void modelTest() {
        UCD_CIMWrapper u = new UCD_CIMWrapper();
        u.organization = new List<UCD_CIMWrapper.Organization>();
        u.ErrorCd = 'ErrorCd';
        u.ErrorDetailsTxt = 'ErrorDetailsTxt';
        u.ErrorDsc = 'ErrorDsc';
        u.AsynchronousRequestId = 'AsynchronousRequestId';
        
        UCD_CIMWrapper.Organization uo = new UCD_CIMWrapper.Organization();
        uo.searchScore = 10;
        uo.snapshot = new UCD_CIMWrapper.Snapshot();
        uo.sourceRecords = new UCD_CIMWrapper.SourceRecords();
        
        UCD_CIMWrapper.Snapshot us = new UCD_CIMWrapper.Snapshot();
        us.BusinessOrganization = new UCD_CIMWrapper.BusinessOrganization();
        us.BusinessOrganizationNm = new List<UCD_CIMWrapper.BusinessOrganizationNm>();
        us.PhysicalAddress = new List<UCD_CIMWrapper.PhysicalAddress>();
        us.ElectronicAddress = new List<UCD_CIMWrapper.ElectronicAddress>();
        us.BusinessOrganizationLegalAgreement = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        us.BusinessOrganizationNAICS = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        us.BusinessOrganizationRoleAssociation = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        us.BusinessOrganizationSIC = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        us.BusinessOrganizationThirdPartyTrustedSourceInfo = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        us.BusinessOrganizationThirdPartyWatchList = new List<UCD_CIMWrapper.BusinessOrganizationThirdPartyWatchList>();
        us.BusinessOrganizationSalesGroup = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        us.BusinessOrganizationGoldStatusAssociation = new UCD_CIMWrapper.BusinessOrganizationGoldStatusAssociation();
        us.BusinessOrganizationTrustedReferenceProcessStatusAssociation = new UCD_CIMWrapper.BusinessOrganizationTrustedReferenceProcessStatusAssociation();
        us.BusinessOrganizationAdditionalEntity = 'BusinessOrganizationAdditionalEntity';
        
        UCD_CIMWrapper.SourceRecords usr = new UCD_CIMWrapper.SourceRecords();
        usr.sourceRecord = new List<UCD_CIMWrapper.SourceRecord>();
        
        UCD_CIMWrapper.BusinessOrganization ub = new UCD_CIMWrapper.BusinessOrganization();
        ub.BusinessOrganizationPartyId = 'BusinessOrganizationPartyId';
        ub.BusinessOrganizationClassificationCd = 'BusinessOrganizationClassificationCd';
        ub.AllIntelNoContactDtm = 'AllIntelNoContactDtm';
        ub.DUNSNumber = 'DUNSNumber';
        ub.EffectiveStartDtm = 'EffectiveStartDtm';
        ub.EffectiveEndDtm = 'EffectiveEndDtm';
        
        UCD_CIMWrapper.BusinessOrganizationNm ubo = new UCD_CIMWrapper.BusinessOrganizationNm();
        ubo.BusinessOrganizationNm = 'BusinessOrganizationNm';
        ubo.BusinessOrganizationNmTypeCd = 'BusinessOrganizationNmTypeCd';
        ubo.GoldenNameInd = 'GoldenNameInd';
        ubo.NonLatinInd = 'NonLatinInd';
        ubo.LanguageCd = 'LanguageCd';
        ubo.EffectiveStartDtm = 'EffectiveStartDtm';
        ubo.EffectiveEndDtm = 'EffectiveEndDtm';
        
        UCD_CIMWrapper.PhysicalAddress up = new UCD_CIMWrapper.PhysicalAddress();
        up.PhysicalStreetAddressTxt = 'PhysicalStreetAddressTxt';
        up.PostOfficeOrLockBoxTxt = 'PostOfficeOrLockBoxTxt';
        up.CityNm ='city';
        up.CountryCd = 'country';
        up.CountryNm = 'country';
        up.CountrySubdivisionCd = 'country';
        up.CountrySubdivisionNm = 'nm';
        up.EffectiveEndDtm = 'date';
        up.EffectiveStartDtm = 'date';
        up.GoldenPhysicalAddressInd = 'address';
        up.LanguageCd = 'language';
        up.NonLatinDataInd = 'data';
        up.PostalCd = 'postal';
        up.PhysicalAddressUsageLocationAssociation = new List<UCD_CIMWrapper.PhysicalAddressUsageLocationAssociation>();
        
        UCD_CIMWrapper.PhysicalAddressUsageLocationAssociation upa = new UCD_CIMWrapper.PhysicalAddressUsageLocationAssociation();
        upa.AddressLocationTypeCd = 'addr';
        upa.AddressUsageTypeCd = 'addr';
        upa.ContactAllowedInd = 'con';
        upa.EffectiveEndDtm = 'eff';
        upa.EffectiveStartDtm = 'start';
        upa.PreferredMethodOfCommunicationInd = 'pre';
        
        UCD_CIMWrapper.ElectronicAddress ue = new UCD_CIMWrapper.ElectronicAddress();
        ue.EffectiveEndDtm = 'eff';
        ue.EffectiveStartDtm = 'eff';
        ue.ElectronicAddressTxt = 'ele';
        ue.ElectronicAddressTypeCd = 'ele';
        ue.GoldenElectronicAddressInd = 'gold';
        ue.ElectronicAddressUsageLocationAssociation = new UCD_CIMWrapper.ElectronicAddressUsageLocationAssociation();
        
        UCD_CIMWrapper.ElectronicAddressUsageLocationAssociation uea = new UCD_CIMWrapper.ElectronicAddressUsageLocationAssociation();
        uea.AddressLocationTypeCd = 'add';
        uea.AddressUsageTypeCd = 'add';
        uea.ContactAllowedInd = 'add';
        uea.EffectiveEndDtm = 'add';
        uea.EffectiveStartDtm = 'add';
        uea.PreferredMethodOfCommunicationInd = 'add';
        
        UCD_CIMWrapper.BusinessOrganizationThirdPartyWatchList ubot = new UCD_CIMWrapper.BusinessOrganizationThirdPartyWatchList();
        ubot.WatchListTypeCd = 'ub';
        ubot.WatchListTypeNm = 'ub';
        ubot.WatchListOrigCd = 'ub';
        ubot.WatchListAssignmentReasonKeyText = 'ub';
        ubot.BusinessReasonText = 'ub';
        ubot.EffectiveStartDtm = 'ub';
        ubot.EffectiveEndDtm = 'ub';
        
        UCD_CIMWrapper.BusinessOrganizationTrustedReferenceProcessStatusAssociation b = new UCD_CIMWrapper.BusinessOrganizationTrustedReferenceProcessStatusAssociation();
        b.EffectiveEndDtm = 'eff';
        b.EffectiveStartDtm = 'eff';
        b.TrustedProcessStatusCd = 'eff';
        
        UCD_CIMWrapper.BusinessOrganizationGoldStatusAssociation bo = new UCD_CIMWrapper.BusinessOrganizationGoldStatusAssociation();
        bo.EffectiveEndDtm = 'eff';
        bo.EffectiveStartDtm = 'eff';
        bo.GoldProcessStatusApprovalStatusCd = 'eff';
        
        UCD_CIMWrapper.SourceRecord ss = new UCD_CIMWrapper.SourceRecord();
        ss.SourceSystemCd = 'SourceSystemCd';
        ss.SourceBusinessOrganizationEngagementDeduplicationGroupAssociation = 'ss';
        ss.SourceBusinessOrganizationSalesGroup = 'SourceBusinessOrganizationSalesGroup';
        ss.SourceBusinessOrganizationSourceSystemTestAttribute = 'SourceBusinessOrganizationSourceSystemTestAttribute';
        ss.SourceBusinessOrganizationAdditionalEntity = 'SourceBusinessOrganizationAdditionalEntity';
        ss.SourceBusinessOrganization =new UCD_CIMWrapper.SourceBusinessOrganization();
        ss.SourceBusinessOrganizationStatus =new UCD_CIMWrapper.SourceBusinessOrganizationStatus();
        ss.SourceBusinessOrganizationNm = new List<UCD_CIMWrapper.SourceBusinessOrganizationNm>();
        ss.SourceElectronicAddress = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();        
        ss.SourceBusinessOrganizationLegalAgreement = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        ss.SourceBusinessOrganizationNAICS = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        ss.SourceBusinessOrganizationRoleAssociation = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        ss.SourceBusinessOrganizationSIC = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        ss.SourceBusinessOrganizationThirdPartyTrustedSourceInfo = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        ss.SourceBusinessOrganizationThirdPartyWatchList = new List<UCD_CIMWrapper.BusinessOrganizationLegalAgreement>();
        ss.SourcePhysicalAddress = new List<UCD_CIMWrapper.PhysicalAddress>();
        
        UCD_CIMWrapper.SourceBusinessOrganizationStatus sb1 = new UCD_CIMWrapper.SourceBusinessOrganizationStatus();
        sb1.StatusTxt = 'StatusTxt';
        
        UCD_CIMWrapper.SourceBusinessOrganization so1 = new UCD_CIMWrapper.SourceBusinessOrganization();
        so1.BusinessOrganizationPartyId = 'SourceBusinessOrganization';
        so1.BusinessOrganizationClassificationCd = 'SourceBusinessOrganization';
        so1.AllIntelNoContactDtm = 'SourceBusinessOrganization';
        so1.DUNSNumber = 'SourceBusinessOrganization';
        so1.EffectiveStartDtm = 'SourceBusinessOrganization';
        so1.EffectiveEndDtm = 'SourceBusinessOrganization';
        
        UCD_CIMWrapper.SourceBusinessOrganizationEngagementDeduplicationGroupAssociation so2 = new UCD_CIMWrapper.SourceBusinessOrganizationEngagementDeduplicationGroupAssociation();
        so2.ActiveInd = 'yes';
        so2.EngagementDeduplicationGroupCd = 'eng';
        
        UCD_CIMWrapper.BusinessOrganizationLegalAgreement n1 = new UCD_CIMWrapper.BusinessOrganizationLegalAgreement();
        
        UCD_CIMWrapper.SourceBusinessOrganizationNm sb3 = new UCD_CIMWrapper.SourceBusinessOrganizationNm();
        sb3.BusinessOrganizationNm = 'SourceBusinessOrganizationNm';
        sb3.BusinessOrganizationNmTypeCd = 'SourceBusinessOrganizationNm';
        sb3.GoldenNameInd = 'SourceBusinessOrganizationNm';
        sb3.NonLatinInd = 'SourceBusinessOrganizationNm';
        sb3.LanguageCd = 'SourceBusinessOrganizationNm';
        sb3.EffectiveStartDtm = 'SourceBusinessOrganizationNm';
        sb3.EffectiveEndDtm = 'SourceBusinessOrganizationNm';
        
    }
}