@isTest
public class Core_IPS_GetProjectOnProducts_Ctrl_Test {
    
    @isTest
    public static void getProjectTest(){
        
       //Added by Sowmya - Start - 28/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
        List<Core_IPS_Project__c> Projlst = TestUtilities.getListOfIpsProjects(1);
        Projlst[0].Name = 'test';
        insert Projlst; 
        
        Product2 prod = TestUtilities.getProduct();
        insert prod;
        
        Core_IPS_Product_Organization__c SupOrg = new Core_IPS_Product_Organization__c(); //SupportOrg
        SupOrg.Core_IPS_Support_Org_Name__c='Trident Solutions';
        SupOrg.Core_Organization_Description__c='This is from portal side';
        insert SupOrg;
        
         List<Core_IPS_Supported_Product__c> ListOfSupportedProduct = TestUtilities.getListOfSupportedProduct(1);
         ListOfSupportedProduct[0].Core_Product__c = prod.Id;
         ListOfSupportedProduct[0].Core_Product_Organization__c=SupOrg.Id;
		 insert ListOfSupportedProduct;
         // Sowmya - End - 28/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
 		
         Asset astList = new Asset();
         List<Asset> AssetList  = TestUtilities.getAssetList(1);
         insert AssetList;
    
         astList = [select Id,core_supported_product__c,Status  from Asset where id =: AssetList[0].id];
         astList.Status = 'Open';
         //Added by Sowmya - Start - 28/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 
		 astList.Core_IPS_Project__c = Projlst[0].Id;
         astList.Core_Supported_Product__c = ListOfSupportedProduct[0].Id;
         //Sowmya - End - 28/10/2024 - TWC745-6800 - Fix test coverage for all failed classes 

         update astList;
        
       system.debug('astList'+astList);
        
          system.assertEquals(true, astList != null) ;
        // Core_IPS_CaseUtility.getIPSProjListBasedOnSelectedProd(astList.id);
    
   		Test.startTest();
		Core_IPS_GetProjectOnProducts_Ctrl.getIPSProjListBasedOnSelectedProd(astList.id, 'test');
        Test.stopTest();
    }
   
}