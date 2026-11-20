/***************************************************************************************************************************
* Test Class  : Level1ProductResponseWrapperTest
* Author And Date  : Rohit Podder, 25 MAY 2026
* Function         : Test class for Level1ProductResponseWrapper
****************************************************************************************************************************/
@isTest
private class Level1ProductResponseWrapperTest {
    
    @isTest
    static void testWrapperDeserialization() {
        String json = '{"categories":[' +
            '{"parentId":"root","sourceId":"873","Name":"Processors"},' +
            '{"parentId":"873","sourceId":"999","Name":"ChildCategory"}' +
            '],"metadata":{"count":2,"limitValue":5000,"offset":1}}';
        
        Level1ProductResponseWrapper wrapper = (Level1ProductResponseWrapper) System.JSON.deserialize(json, Level1ProductResponseWrapper.class);
        
        Assert.areEqual(2, wrapper.categories.size(), 'Should have 2 categories');
        Assert.areEqual('root', wrapper.categories[0].parentId, 'First category parentId should be root');
        Assert.areEqual('873', wrapper.categories[0].sourceId, 'First category sourceId should be 873');
        Assert.areEqual('Processors', wrapper.categories[0].Name, 'First category name should be Processors');
        Assert.areEqual(2, wrapper.metadata.count, 'Metadata count should be 2');
        Assert.areEqual(5000, wrapper.metadata.limitValue, 'Metadata limit should be 5000');
        Assert.areEqual(1, wrapper.metadata.offset, 'Metadata offset should be 1');
    }
    
    @isTest
    static void testEmptyCategories() {
        String json = '{"categories":[],"metadata":{"count":0,"limitValue":5000,"offset":1}}';
        
        Level1ProductResponseWrapper wrapper = (Level1ProductResponseWrapper) System.JSON.deserialize(json, Level1ProductResponseWrapper.class);
        
        Assert.areEqual(0, wrapper.categories.size(), 'Should have no categories');
        Assert.areEqual(0, wrapper.metadata.count, 'Count should be 0');
    }
    
    @isTest
    static void testNullFields() {
        Level1ProductResponseWrapper wrapper = new Level1ProductResponseWrapper();
        Assert.isNull(wrapper.categories, 'Categories should be null by default');
        Assert.isNull(wrapper.metadata, 'Metadata should be null by default');
        
        Level1ProductResponseWrapper.Category cat = new Level1ProductResponseWrapper.Category();
        Assert.isNull(cat.parentId, 'parentId should be null by default');
        Assert.isNull(cat.sourceId, 'sourceId should be null by default');
        Assert.isNull(cat.Name, 'Name should be null by default');
        
        Level1ProductResponseWrapper.Metadata meta = new Level1ProductResponseWrapper.Metadata();
        Assert.isNull(meta.count, 'count should be null by default');
        Assert.isNull(meta.limitValue, 'limitValue should be null by default');
        Assert.isNull(meta.offset, 'offset should be null by default');
    }
}