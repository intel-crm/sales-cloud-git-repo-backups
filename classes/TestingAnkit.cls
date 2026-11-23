public class TestingAnkit{
    static String testString = 'Reshma';
	public static void testMain(){
        	System.debug('testString'+testString);
	
	secondMethod(testString);
	System.debug('testString2'+testString);
	}
	
	public static void secondMethod(String testString1){
	
			testString1 = 'Abhishek';
			System.debug('testString1'+testString1);
	}
}