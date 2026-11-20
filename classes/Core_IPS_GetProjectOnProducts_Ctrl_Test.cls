@isTest
public class Core_IPS_GetProjectOnProducts_Ctrl_Test {
    
    @isTest
    public static void getProjectTest(){
         Asset astList = new Asset();
         List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
         List<Asset> AssetList  = TestUtilities.getAssetList(1);
         insert AssetList;
    
         astList = [select Id,core_supported_product__c,Status  from Asset where id =: AssetList[0].id];
         astList.Status = 'Open';
         update astList;
          system.assertEquals(true, astList != null) ;
        // Core_IPS_CaseUtility.getIPSProjListBasedOnSelectedProd(astList.id);
    
   		Test.startTest();
		Core_IPS_GetProjectOnProducts_Ctrl.getIPSProjListBasedOnSelectedProd(astList.id, 'test');
        Test.stopTest();
    }
   
}