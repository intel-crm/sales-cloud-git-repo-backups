@isTest
private class My_Dummy_ClassTest {

    @isTest
    static void testPerformDummyCalculationSuccess() {
        // Instantiate the class under test
        My_Dummy_Class dummyInstance = new My_Dummy_Class();
        
        Test.startTest();
        Decimal result = dummyInstance.performDummyCalculation(100.00);
        Test.stopTest();
        
        // Assert the expected 10% markup result (110.00)
        System.assertEquals(110.00, result, 'The calculation should apply a 10% markup.');
    }

    @isTest
    static void testPerformDummyCalculationNullInput() {
        My_Dummy_Class dummyInstance = new My_Dummy_Class();
        Boolean exceptionThrown = false;
        
        Test.startTest();
        try {
            dummyInstance.performDummyCalculation(null);
        } catch (IllegalArgumentException e) {
            exceptionThrown = true;
            System.assertEquals('Input value cannot be null.', e.getMessage(), 'The exception message should match.');
        }
        Test.stopTest();
        
        System.assert(exceptionThrown, 'An IllegalArgumentException should have been thrown.');
    }
}