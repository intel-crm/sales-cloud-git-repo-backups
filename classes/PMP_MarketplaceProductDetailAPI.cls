@RestResource(urlMapping='/v1.0/productDetails/product')
global class PMP_MarketplaceProductDetailAPI {
    @HttpPost
    global static String getProductDetails(String offeringId, String langCode){
        
        return 'OfferingDetails';
    }
}