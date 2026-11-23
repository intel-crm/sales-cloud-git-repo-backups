@isTest
public class Retail_CPQ_ExhibitList_Test {
	@testSetup
    public static void setUpData(){
        List<Product2> productList =Retail_CPQ_TestDataSetup.createRSAproducts();
        productList[0].Core_Product_Series__c='10th Generation';
        insert productList;
        List<Core_CPQ_Product_Group__c> productGroupingList= Retail_CPQ_TestDataSetup.createProductGrouping(1);
        insert productGroupingList;
        List<Core_CPQ_Master_Exhibit_List__c> masterExList = new List<Core_CPQ_Master_Exhibit_List__c>();
        for(Integer i=0;i<productList.size()-2;i++){
            Core_CPQ_Master_Exhibit_List__c obj =new Core_CPQ_Master_Exhibit_List__c();
            obj.core_cpq_product__c=productList[i].Id;
            obj.core_cpq_product_group__c=productGroupingList[0].id;
            masterExList.add(obj);
        }
        insert masterExList;
   }
    @isTest
    public static void testFunctionality(){
        List<Product2> productList=[SELECT id,name from Product2 LIMIT 5];
        List<Core_CPQ_Product_Group__c> productGroupingList=[Select id,name from Core_CPQ_Product_Group__c ];
        test.startTest();
        Retail_CPQ_ExhibitList.getAllRetailProducts(productGroupingList[0].id);
        Retail_CPQ_ExhibitList.saveMasterExList(productList,productGroupingList[0].id);
        test.stopTest();
    }
}