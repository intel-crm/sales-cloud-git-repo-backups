@isTest
public class Calculator_Dummy_Test {
    @isTest static void testAdd() {
        System.assertEquals(5, Calculator_Dummy_CCP.add(2, 3));
        System.assertEquals(null, Calculator_Dummy_CCP.add(null, 3));
    }
    @isTest static void testMultiply() {
        System.assertEquals(6, Calculator_Dummy_CCP.multiply(2, 3));
        System.assertEquals(null, Calculator_Dummy_CCP.multiply(null, 3));
    }
}