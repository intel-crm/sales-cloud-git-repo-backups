@IsTest
public class Tooling_CustomFieldsCntrlTest {
    
    @IsTest
    static void testGetCustomFieldIds() {
        // Create a mock response for the first call
        Tooling_CustomFieldMockClass mock1 = new Tooling_CustomFieldMockClass();
        
        // Set the mock to use for the first call
        Test.setMock(HttpCalloutMock.class, mock1);
        
        // Call the method to test
        Test.startTest();
        List<String> customFieldIds = Tooling_CustomFieldsCntrl.getCustomFieldIds();
        Test.stopTest();
    }
    
     @IsTest
    static void testGetUnusedFields() {
        // Create a mock response
        Tooling_UnusedFieldsMockClass mock = new Tooling_UnusedFieldsMockClass();
        Test.setMock(HttpCalloutMock.class, mock);

        // Call the method to test
        List<String> fieldIds = new List<String> { '001xx0000012345' };
        List<Tooling_FieldwrapperClass> unusedFields = Tooling_CustomFieldsCntrl.getUnusedFields(fieldIds);

        // Assertions
        System.assertEquals(1, unusedFields.size());
    }
    
}