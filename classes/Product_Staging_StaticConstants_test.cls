@istest
public class Product_Staging_StaticConstants_test {
    @istest
    static void Product_Staging_StaticConstants_test1() {
        Test.startTest();
        String vphId = Product_Staging_StaticConstants.vphId;
        String vplchId = Product_Staging_StaticConstants.vplchId;
        String ips= Product_Staging_StaticConstants.ips;
        String five = Product_Staging_StaticConstants.five;
        String sales = Product_Staging_StaticConstants.sales;
        String yes = Product_Staging_StaticConstants.yes; 
        String FPH = Product_Staging_StaticConstants.FPH;
        String FPGA_EPMId = Product_Staging_StaticConstants.FPGA_EPMId;
        String OPN_FieldName = Product_Staging_StaticConstants.OPN_FieldName;
        list<string> Product_EpmIdsSet = Product_Staging_StaticConstants.Product_EpmIdsSet ; 
        list<string> Product_EpmNamesSet = Product_Staging_StaticConstants.Product_EpmNamesSet ;
		list<String> Product_EpmIdSetTest = System.Label.Product_EpmIds.split(';') ;
        list<string> Product_EpmNamesSetTest = System.Label.Product_EpmNames.split(';') ; 
        System.assertEquals(vphId,'43');
        System.assertEquals(vplchId,'59');
        System.assertEquals(ips,'IPS');
        System.assertEquals(five,'5');
        System.assertEquals(sales,'Sales');
        System.assertEquals(yes,'Yes');
        System.assertEquals(FPH,'FPH');
        System.assertEquals(FPGA_EPMId,'98836');
        System.assertEquals(OPN_FieldName,'Core_Product_Name__c');
        System.assertEquals(Product_EpmIdsSet, Product_EpmIdSetTest );
        System.assertEquals(Product_EpmNamesSet, Product_EpmNamesSetTest);
        Test.stopTest();
    }
}