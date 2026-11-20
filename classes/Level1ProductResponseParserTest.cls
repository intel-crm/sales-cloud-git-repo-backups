/***************************************************************************************************************************
 * Test Class: Level1ProductResponseParserTest
 * Author And Date: Rohit Podder, 25 MAY 2026
 * Function: Test class for Level1ProductResponseParser
 ****************************************************************************************************************************/
@isTest
public class Level1ProductResponseParserTest {

    @isTest
    static void testParseValidResponse() {
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"_metadata":{"count":3,"limit":5000,"offset":1},"categories":[{"parentId":"root","sourceId":"1001","Name":"Intel Core"},{"parentId":"1001","sourceId":"2001","Name":"Sub Category"},{"parentId":"root","sourceId":"1002","Name":"Intel Xeon"}]}');

        Level1ProductResponseParser parser = new Level1ProductResponseParser();
        Level1ProductResponseWrapper wrapper = parser.parse(mockResponse);

        System.assertNotEquals(null, wrapper);
        System.assertEquals(3, wrapper.metadata.count);
        System.assertEquals(5000, wrapper.metadata.limitValue);
        System.assertEquals(3, wrapper.categories.size());
    }

    @isTest
    static void testExtractRootCategories() {
        Level1ProductResponseWrapper wrapper = new Level1ProductResponseWrapper();
        wrapper.categories = new List<Level1ProductResponseWrapper.Category>();

        Level1ProductResponseWrapper.Category root1 = new Level1ProductResponseWrapper.Category();
        root1.parentId = 'root';
        root1.sourceId = '1001';
        root1.Name = 'Intel Core';
        wrapper.categories.add(root1);

        Level1ProductResponseWrapper.Category child1 = new Level1ProductResponseWrapper.Category();
        child1.parentId = '1001';
        child1.sourceId = '2001';
        child1.Name = 'Sub Category';
        wrapper.categories.add(child1);

        Level1ProductResponseWrapper.Category root2 = new Level1ProductResponseWrapper.Category();
        root2.parentId = 'root';
        root2.sourceId = '1002';
        root2.Name = 'Intel Xeon';
        wrapper.categories.add(root2);

        Level1ProductResponseParser parser = new Level1ProductResponseParser();
        Map<String, String> rootCategories = parser.extractRootCategories(wrapper);

        System.assertEquals(2, rootCategories.size());
        System.assertEquals('1001', rootCategories.get('Intel Core'));
        System.assertEquals('1002', rootCategories.get('Intel Xeon'));
    }

    @isTest
    static void testExtractRootCategoriesNullWrapper() {
        Level1ProductResponseParser parser = new Level1ProductResponseParser();
        Map<String, String> rootCategories = parser.extractRootCategories(null);
        System.assertEquals(0, rootCategories.size());
    }
}