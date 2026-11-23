/***************************************************************************************************************************
* Apex Class Name: ProductHierarchyFieldMapper
* Author And Date: Rohit Podder, 25 MAY 2026
* Function: Maps ProductHierarchyWrapper data to Product_Inbound_Staging__c records
*          (Single Responsibility: Only responsible for field mapping logic)
****************************************************************************************************************************/
public class ProductHierarchyFieldMapper {
    
    private String ipassLoadId;
    
    public ProductHierarchyFieldMapper(String ipassLoadId) {
        this.ipassLoadId = ipassLoadId;
    }
    
    public List<Product_Inbound_Staging__c> mapToStagingRecords(ProductHierarchyWrapper phw, String productType) {
        List<Product_Inbound_Staging__c> listPis = new List<Product_Inbound_Staging__c>();
        if (phw == null || phw.hierarchy == null) {
            return listPis;
        }
        
        for (ProductHierarchyWrapper.HierarchyItem ph : phw.hierarchy) {
            if (ph.dataSource != 'mm_only') {
                Product_Inbound_Staging__c pis = mapSingleRecord(ph, productType);
                mapMmDetails(pis, ph);
                listPis.add(pis);
            }
        }
        return listPis;
    }
    
    private Product_Inbound_Staging__c mapSingleRecord(ProductHierarchyWrapper.HierarchyItem ph, String productType) {
        Product_Inbound_Staging__c pis = new Product_Inbound_Staging__c();
        pis.iPaaS_Load_ID__c = ipassLoadId;
        pis.level_1_epm_id__c = ph.l1;
        pis.level_1_epm_name__c = ph.l1Name;
        pis.level_2_epm_id__c = ph.l2;
        pis.level_2_epm_name__c = ph.l2Name;
        pis.level_3_epm_id__c = ph.l3;
        pis.level_3_epm_name__c = ph.l3Name;
        pis.level_4_epm_id__c = ph.l4;
        pis.level_4_epm_name__c = ph.l4Name;
        pis.level_5_epm_id__c = ph.l5;
        pis.level_5_epm_name__c = ph.l5Name != Null? ph.l5name : ph.l5_name;
        //Ganesh Start
		if (Product_Utility.isProductDeprecationDateEnabled()) {
    		pis.Deactivation_Date__c = parseDeactivationDate(ph.L5DeprecationDate);
		}
		//Ganesh End
        pis.Core_IsActive__c = ph.l5_is_active == 0 ? False : True;
        pis.Core_Unique_ID__c = ph.l5 + ';' + ph.l4 + ';' + ph.l3 + ';' + ph.l2 + ';' + ph.l1;
        pis.Core_Hierarchy_ID__c = productType == 'VPH' ? '43' : '59';
        pis.Core_Hierarchy_Name__c = productType == 'VPH' ? 'Valid Product Hierarchy' : 'Valid Platform CodeName Hierarchy';
        mapAttributes(pis, ph);
        return pis;
    }
    
    //Ganesh Start
	public static Date parseDeactivationDate(String dateValue) {
    	if (String.isBlank(dateValue)) {
        return null;
    	}
        
    	try {
        String normalizedDate = dateValue.trim();

        if (normalizedDate.contains('T')) {
            normalizedDate = normalizedDate.substringBefore('T');
        } else if (normalizedDate.contains(' ')) {
            normalizedDate = normalizedDate.substringBefore(' ');
        }
        return Date.valueOf(normalizedDate);
            
    } catch (Exception ex) {
        System.debug(LoggingLevel.WARN, 'Unable to parse product deactivation date: ' + dateValue);
        return null;
    }
}
//Ganesh End
    
    private void mapAttributes(Product_Inbound_Staging__c pis, ProductHierarchyWrapper.HierarchyItem ph) {
        if (ph.attributes == null || ph.attributes.isEmpty()) {
            return;
        }
        pis.L4_AdvocatedForNewDesign__c = ph.attributes.get('AvailableForNewDesigns-rawvalue') == '1' ? True : False;
        pis.L4_CodenameText__c = ph.attributes.get('CodeNameText-value') != null ? ph.attributes.get('CodeNameText-value') : '';
        pis.L4_CodenameText_rawValue__c = ph.attributes.get('CodeNameText-rawvalue') != null ? ph.attributes.get('CodeNameText-rawvalue') : '';
        pis.L4_CoreCount__c = ph.attributes.get('CoreCount-rawvalue') != null ? ph.attributes.get('CoreCount-rawvalue') : '';
        pis.L4_Filter_Family__c = ph.attributes.get('Filter-Family-value') != null ? ph.attributes.get('Filter-Family-value') : '';
        pis.L4_Filter_Family_rawValue__c = ph.attributes.get('Filter-Family-rawvalue') != null ? ph.attributes.get('Filter-Family-rawvalue') : '';
        pis.L4_LaunchDate__c = ph.attributes.get('LaunchDate-rawvalue') != null ? Date.valueOf(Date.parse(ph.attributes.get('LaunchDate-rawvalue').split(' ')[0]).year() + '-' + String.valueOf((Date.parse(ph.attributes.get('LaunchDate-rawvalue').split(' ')[0])).month()).leftpad(2, '0') + '-' + String.valueOf((Date.parse(ph.attributes.get('LaunchDate-rawvalue').split(' ')[0])).day()).leftpad(2, '0')) : null;
        pis.L4_DesignExpirationDate__c = ph.attributes.get('NewDesignExpirationDate-rawvalue') != null ? Date.valueOf(Date.parse(ph.attributes.get('NewDesignExpirationDate-rawvalue').split(' ')[0]).year() + '-' + String.valueOf((Date.parse(ph.attributes.get('NewDesignExpirationDate-rawvalue').split(' ')[0])).month()).leftpad(2, '0') + '-' + String.valueOf((Date.parse(ph.attributes.get('NewDesignExpirationDate-rawvalue').split(' ')[0])).day()).leftpad(2, '0')) : null;
        pis.L4_MarketSegment__c = ph.attributes.get('MarketSegment-rawvalue') != null ? ph.attributes.get('MarketSegment-rawvalue') : '';
        pis.L4_MaxTDP__c = ph.attributes.get('MaxTDP-value') != null ? ph.attributes.get('MaxTDP-value') : '';
        pis.L4_MaxTDP_rawValue__c = ph.attributes.get('MaxTDP-rawvalue') != null ? ph.attributes.get('MaxTDP-rawvalue') : '';
        pis.L4_ProcessorNumber__c = ph.attributes.get('ProcessorNumber-rawvalue') != null ? ph.attributes.get('ProcessorNumber-rawvalue') : '';
        pis.L4_ProductGroup__c = ph.attributes.get('ProductGroup-value') != null ? ph.attributes.get('ProductGroup-value') : '';
        pis.L4_ProductGroup_rawValue__c = ph.attributes.get('ProductGroup-rawvalue') != null ? ph.attributes.get('ProductGroup-rawvalue') : '';
        pis.L4_Restriction_Level__c = ph.L4RestrictionLevel != null ? String.valueOf(ph.L4RestrictionLevel) : '';
        pis.L4_VProTechnology__c = ph.attributes.get('VProTechnology-rawvalue') != null && ph.attributes.get('VProTechnology-rawvalue') == 'True' ? True : False;
        pis.L4_StatusCode__c = ph.attributes.get('StatusCodeText-rawvalue') != null ? ph.attributes.get('StatusCodeText-rawvalue') : '';
        pis.L4_StableImagePlatformProgramVersion__c = ph.attributes.get('StableImagePlatformProgramVersion-rawvalue') != null && ph.attributes.get('StableImagePlatformProgramVersion-rawvalue') == 'true' ? True : False;
    }
    
    private void mapMmDetails(Product_Inbound_Staging__c pis, ProductHierarchyWrapper.HierarchyItem ph) {
        if (ph.mm_details == null) {
            return;
        }
        
        // Concatenated strings with mmid prefix (original format: "mmid-value;mmid-value;...")
        String customCustomerCode = '';
        String customIndicator = '';
        String division_withBracket = '';
        String division_withoutBracket = '';
        String familyName = '';
        String groupWithBracket = '';
        String groupWithoutBracket = '';
        String materialStatusCode = '';
        String opCode = '';
        String orderingCode = '';
        String productClass = '';
        String mmId = '';
        String productDescription = '';
        String restrictionCode = '';
        //String profitCenterDescription = '';
        String profitCenter = '';
        String subComponentCategoryName = '';
        String marketCodeName= '';
        
        
        // Distinct value sets (without mmid prefix)
        Set<String> setCustomCustomerCode = new Set<String>();
        Set<String> setCustomIndicator = new Set<String>();
        Set<String> setDivision_withBracket = new Set<String>();
        Set<String> setDivision_withoutBracket = new Set<String>();
        Set<String> setFamilyName = new Set<String>();
        Set<String> setGroup_withBracket = new Set<String>();
        Set<String> setGroup_withoutBracket = new Set<String>();
        Set<String> setMaterialStatusCode = new Set<String>();
        Set<String> setOpCode = new Set<String>();
        Set<String> setOrderingCode = new Set<String>();
        Set<String> setProductClass = new Set<String>();
        Set<String> setProductDescription = new Set<String>();
        Set<String> setProfitCenter = new Set<String>();
        Set<String> lineOfBusiness = new Set<String>();
        Set<String> lineOfBusinessDescription=new Set<String>();
        Set<String> setProfitCenterDescription= new Set<String>();
        Set<String> setMarketCodeName = new Set<String>();
        Set<String> setsubComponentCategoryName = new Set<String>();
        
        
        
        for (ProductHierarchyWrapper.MmDetail pm : ph.mm_details) {
            customCustomerCode += pm.attributes.get('CustomCustomerCode') != null ? pm.mmid + '-' + pm.attributes.get('CustomCustomerCode') + ';' : '';
            customIndicator += pm.attributes.get('CustomIndicator') != null ? pm.mmid + '-' + pm.attributes.get('CustomIndicator') + ';' : '';
            division_withBracket += pm.attributes.get('Division') != null ? pm.mmid + '-' + pm.attributes.get('Division').subStringBetween('(', ')') + ';' : '';
            division_withoutBracket += pm.attributes.get('Division') != null ? pm.mmid + '-' + pm.attributes.get('Division').subStringBefore('(') + ';' : '';
            familyName += pm.attributes.get('FamilyName') != null ? pm.mmid + '-' + pm.attributes.get('FamilyName') + ';' : '';
            groupWithBracket += pm.attributes.get('Group') != null ? pm.mmid + '-' + pm.attributes.get('Group').subStringBetween('(', ')') + ';' : '';
            groupWithoutBracket += pm.attributes.get('Group') != null ? pm.mmid + '-' + pm.attributes.get('Group').subStringBefore('(') + ';' : '';
            materialStatusCode += pm.attributes.get('MaterialStatusCode') != null ? pm.mmid + '-' + pm.attributes.get('MaterialStatusCode') + ';' : '';
            opCode += pm.attributes.get('OpCode') != null ? pm.mmid + '-' + pm.attributes.get('OpCode') + ';' : '';
            orderingCode += pm.attributes.get('OrderingCode') != null ? pm.mmid + '-' + pm.attributes.get('OrderingCode') + ';' : '';
            productClass += pm.attributes.get('ProductClass') != null ? pm.mmid + '-' + pm.attributes.get('ProductClass') + ';' : '';
            //profitCenterDescription += pm.attributes.get('ProfitCenterDescription') != null ? pm.mmid + '-' + pm.attributes.get('ProfitCenterDescription') + ';' : '';
            productDescription += pm.attributes.get('MaterialDescription') != null ? pm.mmid + '-' + pm.attributes.get('MaterialDescription') + ';' : '';
            mmId += pm.mmid + ';';
            restrictionCode += pm.restrictionLevel != null ? pm.mmid + '-' + pm.restrictionLevel + ';' : '';
            subComponentCategoryName += pm.attributes.get('SubComponentCategoryName') != null ? pm.mmid + '-' + pm.attributes.get('SubComponentCategoryName') + ';' : '';
            marketCodeName += pm.attributes.get('MarketCodeName') != null ? pm.mmid + '-' + pm.attributes.get('MarketCodeName') + ';' : '';
            profitCenter += pm.attributes.get('ProfitCenter') != Null ? pm.mmid +'-' +pm.attributes.get('ProfitCenter')+';':'';
            String profitCentr = pm.attributes.get('ProfitCenter') != null ? pm.attributes.get('ProfitCenter') : '';
            String profitCenterDesc = pm.attributes.get('ProfitCenterDescription') != null ? pm.attributes.get('ProfitCenterDescription') : '';
            if (String.isNotBlank(profitCentr) || String.isNotBlank(profitCenterDesc)) {
                setProfitCenterDescription.add(profitCentr + '-' + profitCenterDesc);
            }
            setProfitCenterDescription.remove('Null');
            String lob= pm.attributes.get('LineOfBusiness') != null ? pm.attributes.get('LineOfBusiness') : '';
            String lineOfBusineesCode='';
            if(lob.contains('(') && lob.contains(')')){
                lineOfBusineesCode= lob.subStringBetween('(',')');
            }
            if(String.isNotBlank(lineOfBusineesCode)) {
                lineOfBusiness.add(lineOfBusineesCode);
            }
            lineOfBusiness.remove('Null');
            String lobDescription=pm.attributes.get('LineOfBusiness') != null ? pm.attributes.get('LineOfBusiness') : '';
            if (String.isNotBlank(lobDescription)) {
                lineOfBusinessDescription.add(lobDescription);
            }
            lineOfBusinessDescription.remove('Null');
            // Distinct value sets
            setCustomCustomerCode.add(pm.attributes.get('CustomCustomerCode'));
            setCustomCustomerCode.remove(null);
            setCustomIndicator.add(pm.attributes.get('CustomIndicator'));
            setCustomIndicator.remove(null);
            if (pm.attributes.get('Division') != null) {
                setDivision_withBracket.add(pm.attributes.get('Division').subStringBetween('(', ')'));
                setDivision_withoutBracket.add(pm.attributes.get('Division').subStringBefore('(').trim());
            }
            setFamilyName.add(pm.attributes.get('FamilyName'));
            setFamilyName.remove(null);
            if (pm.attributes.get('Group') != null) {
                setGroup_withBracket.add(pm.attributes.get('Group').subStringBetween('(', ')'));
                setGroup_withoutBracket.add(pm.attributes.get('Group').subStringBefore('('));
            }
            setMaterialStatusCode.add(pm.attributes.get('MaterialStatusCode'));
            setMaterialStatusCode.remove(null);
            setOpCode.add(pm.attributes.get('OpCode'));
            setOpCode.remove(null);
            setOrderingCode.add(pm.attributes.get('OrderingCode'));
            setOrderingCode.remove(null);
            setProductClass.add(pm.attributes.get('ProductClass'));
            setProductClass.remove(null);
            setProductDescription.add(pm.attributes.get('MaterialDescription'));
            setProductDescription.remove(null);
            setProfitCenter.add(pm.attributes.get('ProfitCenter'));
            setProfitCenter.remove(null);
            setMarketCodeName.add(pm.attributes.get('MarketCodeName'));
            setMarketCodeName.remove(null);
            setsubComponentCategoryName.add(pm.attributes.get('SubComponentCategoryName'));
            setsubComponentCategoryName.remove(null);
        }
        
        // Concatenated fields with mmid prefix
        pis.L5_CustomCustomerCode__c = customCustomerCode.removeEnd(';');
        pis.L5_CustomIndicator__c = customIndicator.removeEnd(';');
        pis.L5_Division_withBracket__c = division_withBracket.removeEnd(';');
        pis.L5_Division_withoutBracket__c = division_withoutBracket.removeEnd(';');
        pis.L5_FamilyName__c = familyName.removeEnd(';');
        pis.L5_Group_withBracket__c = groupWithBracket.removeEnd(';');
        pis.L5_Group_withoutBracket__c = groupWithoutBracket.removeEnd(';');
        pis.L5_MaterialStatusCode__c = materialStatusCode.removeEnd(';');
        pis.L5_Opcode__c = opCode.removeEnd(';');
        pis.L5_OrderingCode__c = orderingCode.removeEnd(';');
        pis.L5_ProductClass__c = productClass.removeEnd(';');
        pis.L5_ProductDescription__c = productDescription.removeEnd(';');
        //pis.L5_Profit_Center_Description__c = profitCenterDescription.removeEnd(';');
        pis.L5_mmid__c = mmId.removeEnd(';');
        pis.Restriction_Code__c = restrictionCode.removeEnd(';');
        pis.L5_ProfitCenter__c = profitCenter.removeEnd(';');
        pis.L4_Sub_Component_Category__c = subComponentCategoryName.removeEnd(';');
        pis.L5_MarketCodeName__c = marketCodeName.removeEnd(';');
        
        // Distinct value fields (without repetition/without mmid prefix)
        pis.L5_CustomCustomerCode_WOR__c = String.join(new List<String>(setCustomCustomerCode), ';');
        pis.L5_CustomCustomerCode_WR__c = String.join(new List<String>(setCustomCustomerCode), ';');
        pis.L5_CustomIndicator_WOR__c = String.join(new List<String>(setCustomIndicator), ';');
        pis.L5_CustomIndicator_WR__c = String.join(new List<String>(setCustomIndicator), ';');
        pis.L5_Division_withBracket_WOR__c = String.join(new List<String>(setDivision_withBracket), ';');
        pis.L5_Division_withBracket_WR__c = String.join(new List<String>(setDivision_withBracket), ';');
        pis.L5_Division_withoutBracket_WOR__c = String.join(new List<String>(setDivision_withoutBracket), ';');
        pis.L5_Division_withoutBracket_WR__c = String.join(new List<String>(setDivision_withoutBracket), ';');
        pis.L5_FamilyName_WOR__c = String.join(new List<String>(setFamilyName), ';');
        pis.L5_FamilyName_WR__c = String.join(new List<String>(setFamilyName), ';');
        pis.L5_Group_withBracket_WOR__c = String.join(new List<String>(setGroup_withBracket), ';');
        pis.L5_Group_withBracket_WR__c = String.join(new List<String>(setGroup_withBracket), ';');
        pis.L5_Group_withoutBracket_WR__c = String.join(new List<String>(setGroup_withoutBracket), ';');
        pis.L5_Group_withoutBracket_WOR__c = String.join(new List<String>(setGroup_withoutBracket), ';');
        pis.L5_MaterialStatusCode_WOR__c = String.join(new List<String>(setMaterialStatusCode), ';');
        pis.L5_MaterialStatusCode_WR__c = String.join(new List<String>(setMaterialStatusCode), ';');
        pis.L5_Opcode_WOR__c = String.join(new List<String>(setOpCode), ';');
        pis.L5_Opcode_WR__c = String.join(new List<String>(setOpCode), ';');
        pis.L5_OrderingCode_WOR__c = String.join(new List<String>(setOrderingCode), ';');
        pis.L5_OrderingCode_WR__c = String.join(new List<String>(setOrderingCode), ';');
        pis.L5_ProductClass_WOR__c = String.join(new List<String>(setProductClass), ';');
        pis.L5_ProductClass_WR__c = String.join(new List<String>(setProductClass), ';');
        pis.L5_ProductDescription_WOR__c = String.join(new List<String>(setProductDescription), ';');
        pis.L5_ProductDescription_WR__c = String.join(new List<String>(setProductDescription), ';');
        pis.L5_mmid_WR__c = mmId.removeEnd(';');
        pis.Is_MMID_Blank__c = String.isBlank(mmId) ? true : false;
        pis.L5_ProfitCenter_WR__c = String.join(new List<String>(setProfitCenter), ';');
        pis.L5_ProfitCenter_WOR__c = String.join(new List<String>(setProfitCenter), ';');   
        pis.L5_Line_of_Business__c= String.join(lineOfBusiness,';');
        pis.L5_Line_Of_Business_Description__c=String.join(lineOfBusinessDescription,';');
        pis.L5_Profit_Center_Description__c= String.join(setProfitCenterDescription,';');
        pis.L4_Sub_Component_Category_WOR__c = String.join(setsubComponentCategoryName, ';');
        pis.L4_Sub_Component_Category_WR__c = String.join(setsubComponentCategoryName, ';');
        pis.L5_MarketCodeName_WOR__c = String.join(setMarketCodeName, ';');
        pis.L5_MarketCodeName_WR__c = String.join(setMarketCodeName, ';');
        
    }
}