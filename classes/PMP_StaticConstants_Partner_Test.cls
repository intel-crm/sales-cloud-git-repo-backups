@isTest
public class PMP_StaticConstants_Partner_Test {
    public static testMethod void testStaticMethod(){
        PMP_Static_Constants__c sc = new PMP_Static_Constants__c();
        sc.Name = 'PMP_Product';
        sc.PMP_Value__c = 'product';
        insert sc;
        
        Test.StartTest();
        PMP_StaticConstants_Partner testClass = new PMP_StaticConstants_Partner();
        System.AssertEquals('product',PMP_StaticConstants_Partner.product);
        Test.StopTest();
    }

}