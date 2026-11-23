public with sharing class productController {
    public productController() {

    }
    /*@AuraEnabled(cacheable=true)
    public static List<Product2>getProducts(){
        return [SELECT Id, Name FROM Product2 LIMIT 10];
    }*/
    @AuraEnabled(cacheable=true)
    public static List<Product2>getProducts(){
        return [SELECT Id, Name FROM Product2 ];
    }
}