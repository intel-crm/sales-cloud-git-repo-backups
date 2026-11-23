@isTest
public class Quest_Dummy_CalculatorTest {
    
    @isTest
    static void testAdd() {
        Integer result = Quest_Dummy_Calculator.add(5, 3);
        System.assertEquals(8, result, 'Addition should return 8');
    }
    
    @isTest
    static void testMultiply() {
        Integer result = Quest_Dummy_Calculator.multiply(4, 3);
        System.assertEquals(12, result, 'Multiplication should return 12');
    }
    
    @isTest
    static void testMultiplyWithZero() {
        Integer result = Quest_Dummy_Calculator.multiply(0, 5);
        System.assertEquals(0, result, 'Multiplication with zero should return 0');
    }
}