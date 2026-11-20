@isTest
public class pricing_HomePageControllerTest {
    
    @isTest
    public static void test_getQuoteLineListViews() {

        List<User> lstUsers2 = Pricing_Test_Utility.createAdminUser();
        System.runAs(lstUsers2[0]){

            Test.startTest();
            List<ListView> listV = new List<ListView>();
            listV = pricing_HomePageController.getListViewValues('SBQQ__QuoteLine__c');
            System.assert((listv.size() > 0),'Success');
            Test.stopTest();
        }            
    }
}