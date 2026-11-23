@isTest
public class Dummy_Calculator_Test {
    @isTest static void testAdd() {
        System.assertEquals(5, Calculator_Dummy_IPA.add(2, 3));
        System.assertEquals(null, Calculator_Dummy_IPA.add(null, 3));
    }
    @isTest static void testMultiply() {
        System.assertEquals(6, Calculator_Dummy_IPA.multiply(2, 3));
        System.assertEquals(null, Calculator_Dummy_IPA.multiply(null, 3));
    }
}