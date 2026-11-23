@isTest
public class PMP_StaticConstants_Offering_Test {
    public static testMethod void testStaticMethod(){
        Test.StartTest();
        PMP_StaticConstants_Offering testClass = new PMP_StaticConstants_Offering();
        System.AssertEquals('Grabage Symbols',PMP_StaticConstants_Offering.garbage_Symbols);
        
        Test.StopTest();
    }
    
}