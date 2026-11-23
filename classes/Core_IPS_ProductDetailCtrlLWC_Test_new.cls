@isTest
public class Core_IPS_ProductDetailCtrlLWC_Test_new {
@isTest
    public static void getProductTest(){
        Asset assetObj = new Asset();
        assetObj.Name = 'Intel';
        insert assetObj;
        apexpages.currentpage().getparameters().put('recordId',assetObj.Id);
        Core_IPS_ProductDetailPrint_Ctrl prodPrintObj = new Core_IPS_ProductDetailPrint_Ctrl();
            prodPrintObj.getAllCases(); 
    }
   public static void getProductTest1(){
        
        Core_IPS_ProductDetailPrint_Ctrl prodPrintObj = new Core_IPS_ProductDetailPrint_Ctrl();
            prodPrintObj.getAllCases(); 
    }
}