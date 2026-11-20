@IsTest
public class UCD_ACM_LoggerTest {
    
    @IsTest
    public static void whenInformation(){
        Test.startTest();
        UCD_ACM_Logger logger = new UCD_ACM_Logger();
        UCD_ACM_Logger.information('TestClass', 'TestMethod', 'TestMessage','Tags');
        UCD_ACM_Logger.setLogDetails();
        Test.stopTest();
    }
    @IsTest
    public static void whenWaring(){
        Test.startTest();
        UCD_ACM_Logger logger = new UCD_ACM_Logger();
        UCD_ACM_Logger.warning('TestClass', 'TestMethod', 'TestMessage','Tags');
        UCD_ACM_Logger.setLogDetails();
        Test.stopTest();
    }
    @IsTest
    public static void whenError(){
        Test.startTest();
        UCD_ACM_Logger logger = new UCD_ACM_Logger();
        UCD_ACM_Logger.error('TestClass', 'TestMethod', 'TestMessage','Tags');
        UCD_ACM_Logger.setLogDetails();
        Test.stopTest();
    }
    
}