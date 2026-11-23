/***************************************************************************************************************************
Apex Class Name  : ProductHierarchyWrapperTest
Author And Date  : Rohit Podder, 23 MAR 2026
Function         : Test class for ProductHierarchyWrapper class
****************************************************************************************************************************/
@isTest
public class ProductHierarchyWrapperTest {
    
    @isTest
    static void testProductHierarchyWrapperCreation() {
        // Test creating ProductHierarchyWrapper with basic properties
        ProductHierarchyWrapper wrapper = new ProductHierarchyWrapper();
        wrapper.count = '100';
        wrapper.offset = 10;
        wrapper.hierarchy = new List<ProductHierarchyWrapper.HierarchyItem>();
        
        // Assertions
        System.assertEquals('100', wrapper.count, 'Count should be set correctly');
        System.assertEquals(10, wrapper.offset, 'Offset should be set correctly');
        System.assertNotEquals(null, wrapper.hierarchy, 'Hierarchy list should be initialized');
        System.assertEquals(0, wrapper.hierarchy.size(), 'Hierarchy list should be empty initially');
    }
    
    @isTest
    static void testHierarchyItemCreation() {
        // Test creating HierarchyItem with all properties
        ProductHierarchyWrapper wrapper = new ProductHierarchyWrapper();
        ProductHierarchyWrapper.HierarchyItem item = new ProductHierarchyWrapper.HierarchyItem();
        
        // Set all level properties
        item.l1 = 'L1_001';
        item.l1Name = 'Level 1 Category';
        item.l1_is_active = 1;
        
        item.l2 = 'L2_001';
        item.l2name = 'Level 2 Category';
        item.l2_is_active = 1;
        
        item.l3 = 'L3_001';
        item.l3name = 'Level 3 Category';
        item.l3_is_active = 1;
        
        item.l4 = 'L4_001';
        item.l4name = 'Level 4 Category';
        item.l4_is_active = 1;
        item.l4RestrictionLevel = 2;
        
        item.l5 = 'L5_001';
        item.l5name = 'Level 5 Category';
        item.l5_is_active = 0;
        
        item.dataSource = 'TEST_SOURCE';
        
        // Initialize attributes map
        item.attributes = new Map<String, String>();
        item.attributes.put('color', 'red');
        item.attributes.put('size', 'large');
        
        // Initialize mm_details list
        item.mm_details = new List<ProductHierarchyWrapper.MmDetail>();
        
        // Assertions for Level 1
        System.assertEquals('L1_001', item.l1, 'L1 should be set correctly');
        System.assertEquals('Level 1 Category', item.l1Name, 'L1 name should be set correctly');
        System.assertEquals(1, item.l1_is_active, 'L1 active status should be set correctly');
        
        // Assertions for Level 2
        System.assertEquals('L2_001', item.l2, 'L2 should be set correctly');
        System.assertEquals('Level 2 Category', item.l2name, 'L2 name should be set correctly');
        System.assertEquals(1, item.l2_is_active, 'L2 active status should be set correctly');
        
        // Assertions for Level 3
        System.assertEquals('L3_001', item.l3, 'L3 should be set correctly');
        System.assertEquals('Level 3 Category', item.l3name, 'L3 name should be set correctly');
        System.assertEquals(1, item.l3_is_active, 'L3 active status should be set correctly');
        
        // Assertions for Level 4
        System.assertEquals('L4_001', item.l4, 'L4 should be set correctly');
        System.assertEquals('Level 4 Category', item.l4name, 'L4 name should be set correctly');
        System.assertEquals(1, item.l4_is_active, 'L4 active status should be set correctly');
        System.assertEquals(2, item.l4RestrictionLevel, 'L4 restriction level should be set correctly');
        
        // Assertions for Level 5
        System.assertEquals('L5_001', item.l5, 'L5 should be set correctly');
        System.assertEquals('Level 5 Category', item.l5name, 'L5 name should be set correctly');
        System.assertEquals(0, item.l5_is_active, 'L5 active status should be set correctly');
 
    }
}