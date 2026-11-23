/***************************************************************************************************************************
 * Test Class: ProductHierarchyFieldMapperTest
 * Author And Date: Rohit Podder, 25 MAY 2026
 * Function: Test class for ProductHierarchyFieldMapper - validates field mapping logic
 ****************************************************************************************************************************/
@isTest
public class ProductHierarchyFieldMapperTest {

    @isTest
    static void testMapToStagingRecordsWithValidData() {
        ProductHierarchyWrapper phw = new ProductHierarchyWrapper();
        phw.hierarchy = new List<ProductHierarchyWrapper.HierarchyItem>();

        ProductHierarchyWrapper.HierarchyItem item = new ProductHierarchyWrapper.HierarchyItem();
        item.l1 = '1001';
        item.l1Name = 'Level 1';
        item.l2 = '2001';
        item.l2Name = 'Level 2';
        item.l3 = '3001';
        item.l3Name = 'Level 3';
        item.l4 = '4001';
        item.l4Name = 'Level 4';
        item.l5 = '5001';
        item.l5Name = 'Level 5';
        item.l5_is_active = 1;
        item.dataSource = 'pim';
        item.attributes = new Map<String, String>();
        item.mm_details = null;
        phw.hierarchy.add(item);

        ProductHierarchyFieldMapper mapper = new ProductHierarchyFieldMapper('testLoadId');

        Test.startTest();
        List<Product_Inbound_Staging__c> results = mapper.mapToStagingRecords(phw, 'VPH');
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('testLoadId', results[0].iPaaS_Load_ID__c);
        System.assertEquals('1001', results[0].level_1_epm_id__c);
        System.assertEquals('5001;4001;3001;2001;1001', results[0].Core_Unique_ID__c);
        System.assertEquals('43', results[0].Core_Hierarchy_ID__c);
        System.assertEquals('Valid Product Hierarchy', results[0].Core_Hierarchy_Name__c);
        System.assertEquals(true, results[0].Core_IsActive__c);
    }

    @isTest
    static void testMapToStagingRecordsVPLCH() {
        ProductHierarchyWrapper phw = new ProductHierarchyWrapper();
        phw.hierarchy = new List<ProductHierarchyWrapper.HierarchyItem>();

        ProductHierarchyWrapper.HierarchyItem item = new ProductHierarchyWrapper.HierarchyItem();
        item.l1 = '1001';
        item.l1Name = 'Level 1';
        item.l2 = '2001';
        item.l2Name = 'Level 2';
        item.l3 = '3001';
        item.l3Name = 'Level 3';
        item.l4 = '4001';
        item.l4Name = 'Level 4';
        item.l5 = '5001';
        item.l5Name = 'Level 5';
        item.l5_is_active = 0;
        item.dataSource = 'pim';
        item.attributes = null;
        item.mm_details = null;
        phw.hierarchy.add(item);

        ProductHierarchyFieldMapper mapper = new ProductHierarchyFieldMapper('testLoadId');

        Test.startTest();
        List<Product_Inbound_Staging__c> results = mapper.mapToStagingRecords(phw, 'VPLCH');
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals('59', results[0].Core_Hierarchy_ID__c);
        System.assertEquals('Valid Platform CodeName Hierarchy', results[0].Core_Hierarchy_Name__c);
        System.assertEquals(false, results[0].Core_IsActive__c);
    }

    @isTest
    static void testMapToStagingRecordsSkipsMmOnly() {
        ProductHierarchyWrapper phw = new ProductHierarchyWrapper();
        phw.hierarchy = new List<ProductHierarchyWrapper.HierarchyItem>();

        ProductHierarchyWrapper.HierarchyItem item = new ProductHierarchyWrapper.HierarchyItem();
        item.l1 = '1001';
        item.l1Name = 'Level 1';
        item.l2 = '2001';
        item.l2Name = 'Level 2';
        item.l3 = '3001';
        item.l3Name = 'Level 3';
        item.l4 = '4001';
        item.l4Name = 'Level 4';
        item.l5 = '5001';
        item.l5Name = 'Level 5';
        item.l5_is_active = 1;
        item.dataSource = 'mm_only';
        item.attributes = null;
        item.mm_details = null;
        phw.hierarchy.add(item);

        ProductHierarchyFieldMapper mapper = new ProductHierarchyFieldMapper('testLoadId');

        Test.startTest();
        List<Product_Inbound_Staging__c> results = mapper.mapToStagingRecords(phw, 'VPH');
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    @isTest
    static void testMapToStagingRecordsWithNullWrapper() {
        ProductHierarchyFieldMapper mapper = new ProductHierarchyFieldMapper('testLoadId');

        Test.startTest();
        List<Product_Inbound_Staging__c> results = mapper.mapToStagingRecords(null, 'VPH');
        Test.stopTest();

        System.assertEquals(0, results.size());
    }

    @isTest
    static void testMapToStagingRecordsWithAttributes() {
        ProductHierarchyWrapper phw = new ProductHierarchyWrapper();
        phw.hierarchy = new List<ProductHierarchyWrapper.HierarchyItem>();

        ProductHierarchyWrapper.HierarchyItem item = new ProductHierarchyWrapper.HierarchyItem();
        item.l1 = '1001';
        item.l1Name = 'Level 1';
        item.l2 = '2001';
        item.l2Name = 'Level 2';
        item.l3 = '3001';
        item.l3Name = 'Level 3';
        item.l4 = '4001';
        item.l4Name = 'Level 4';
        item.l5 = '5001';
        item.l5Name = 'Level 5';
        item.l5_is_active = 1;
        item.dataSource = 'pim';
        item.attributes = new Map<String, String>{
            'AvailableForNewDesigns-rawvalue' => 'true',
            'CodeNameText-value' => 'Raptor Lake',
            'CodeNameText-rawvalue' => 'raptor_lake',
            'CoreCount-rawvalue' => '8',
            'Filter-Family-value' => 'Core i7',
            'Filter-Family-rawvalue' => 'core_i7'
        };
        item.mm_details = null;
        phw.hierarchy.add(item);

        ProductHierarchyFieldMapper mapper = new ProductHierarchyFieldMapper('testLoadId');

        Test.startTest();
        List<Product_Inbound_Staging__c> results = mapper.mapToStagingRecords(phw, 'VPH');
        Test.stopTest();

        System.assertEquals(1, results.size());
        System.assertEquals(false, results[0].L4_AdvocatedForNewDesign__c);
        System.assertEquals('Raptor Lake', results[0].L4_CodenameText__c);
        System.assertEquals('8', results[0].L4_CoreCount__c);
    }

    @isTest
    static void testMapToStagingRecordsWithMmDetails() {
        ProductHierarchyWrapper phw = new ProductHierarchyWrapper();
        phw.hierarchy = new List<ProductHierarchyWrapper.HierarchyItem>();

        ProductHierarchyWrapper.HierarchyItem item = new ProductHierarchyWrapper.HierarchyItem();
        item.l1 = '1001';
        item.l1Name = 'Level 1';
        item.l2 = '2001';
        item.l2Name = 'Level 2';
        item.l3 = '3001';
        item.l3Name = 'Level 3';
        item.l4 = '4001';
        item.l4Name = 'Level 4';
        item.l5 = '5001';
        item.l5Name = 'Level 5';
        item.l5_is_active = 1;
        item.dataSource = 'pim';
        item.attributes = new Map<String, String>();

        // Create mm_details
        ProductHierarchyWrapper.MmDetail mm1 = new ProductHierarchyWrapper.MmDetail();
        mm1.mmid = 'MM001';
        mm1.restrictionLevel = 3;
        mm1.attributes = new Map<String, String>{
            'CustomCustomerCode' => 'CCC1',
            'CustomIndicator' => 'CI1',
            'Division' => 'Div A(DA)',
            'FamilyName' => 'Fam1',
            'Group' => 'Grp X(GX)',
            'MaterialStatusCode' => 'Active',
            'OpCode' => 'OP1',
            'OrderingCode' => 'OC1',
            'ProductClass' => 'PC1',
            'MaterialDescription' => 'Desc1',
            'ProfitCenterDescription' => 'PCD1',
            'ProfitCenter' => 'P100'
        };

        ProductHierarchyWrapper.MmDetail mm2 = new ProductHierarchyWrapper.MmDetail();
        mm2.mmid = 'MM002';
        mm2.restrictionLevel = null;
        mm2.attributes = new Map<String, String>{
            'CustomCustomerCode' => 'CCC2',
            'OrderingCode' => 'OC2'
        };

        item.mm_details = new List<ProductHierarchyWrapper.MmDetail>{ mm1, mm2 };
        phw.hierarchy.add(item);

        ProductHierarchyFieldMapper mapper = new ProductHierarchyFieldMapper('testLoadId');

        Test.startTest();
        List<Product_Inbound_Staging__c> results = mapper.mapToStagingRecords(phw, 'VPH');
        Test.stopTest();

        System.assertEquals(1, results.size());
        Product_Inbound_Staging__c pis = results[0];

        // Verify concatenated mmid-prefixed fields
        System.assertEquals('MM001-CCC1;MM002-CCC2', pis.L5_CustomCustomerCode__c);
        System.assertEquals('MM001-CI1', pis.L5_CustomIndicator__c);
        System.assertEquals('MM001-DA', pis.L5_Division_withBracket__c);
        System.assertEquals('MM001-Div A', pis.L5_Division_withoutBracket__c);
        System.assertEquals('MM001-Fam1', pis.L5_FamilyName__c);
        System.assertEquals('MM001-GX', pis.L5_Group_withBracket__c);
        System.assertEquals('MM001-Grp X', pis.L5_Group_withoutBracket__c);
        System.assertEquals('MM001-Active', pis.L5_MaterialStatusCode__c);
        System.assertEquals('MM001-OP1', pis.L5_Opcode__c);
        System.assertEquals('MM001-OC1;MM002-OC2', pis.L5_OrderingCode__c);
        System.assertEquals('MM001-PC1', pis.L5_ProductClass__c);
        System.assertEquals('MM001-Desc1', pis.L5_ProductDescription__c);
        System.assertEquals('MM001;MM002', pis.L5_mmid__c);
        System.assertEquals('MM001-3', pis.Restriction_Code__c);

        // Verify distinct WOR/WR fields
        System.assert(pis.L5_CustomCustomerCode_WOR__c.contains('CCC1'));
        System.assert(pis.L5_CustomCustomerCode_WOR__c.contains('CCC2'));
        System.assert(pis.L5_OrderingCode_WOR__c.contains('OC1'));
        System.assert(pis.L5_OrderingCode_WOR__c.contains('OC2'));
        System.assertEquals(false, pis.Is_MMID_Blank__c);
        System.assert(pis.L5_ProfitCenter_WR__c.contains('P100'));
    }
}