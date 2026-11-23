@isTest
public class Dummy_Calculator_Test_MP {
	@isTest static void testAdd() {
        System.assertEquals(5, Calculator_Dummy_IPA_MP.add(2, 3));
        System.assertEquals(null, Calculator_Dummy_IPA_MP.add(null, 3));
    }
    @isTest static void testMultiply() {
        System.assertEquals(6, Calculator_Dummy_IPA_MP.multiply(2, 3));
        System.assertEquals(null, Calculator_Dummy_IPA_MP.multiply(null, 3));
    }
}