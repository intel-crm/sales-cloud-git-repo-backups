public class fetchProducts {

    @AuraEnabled(cacheable=true)
    public static List<Product2> Details(){
        List<Product2> productDetail = new List<Product2>();
        productDetail = [select Id, Name, Description, ProductCode,StockKeepingUnit, DisplayUrl from Product2 where DisplayUrl = 'https://i.pinimg.com/736x/71/b3/e4/71b3e4159892bb319292ab3b76900930.jpg'];
        return productDetail;
    }
		
}