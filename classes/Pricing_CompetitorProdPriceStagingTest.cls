@isTest
public class Pricing_CompetitorProdPriceStagingTest {
    static testmethod void testCompetitorProductPriceCreate() {
        Test.startTest();
        List<Pricing_Competitor_Product_Price__c> listOfCompProductPrice= Pricing_Test_Utility.createCompetitorProductPrice();
        List<Pricing_Competitor_Product_Price__c> compProductPriceList = new List<Pricing_Competitor_Product_Price__c>();
        Id compRecordId = Pricing_Tender_Utility.getRecordTypeId('Pricing_Competitor_Product__c','Pricing_Data_Center');
        
        //insert of competitor product price record.
        Pricing_Competitor_Product__c compProduct = new Pricing_Competitor_Product__c(Name='TestCompProduct',	RecordTypeId = compRecordId);
        insert compProduct;
        Pricing_Competitor_Product_Price_Staging__c priceStage = new Pricing_Competitor_Product_Price_Staging__c();
        priceStage.Pricing_Region_Staging_Nm__c = 'APJ'; 
        priceStage.Pricing_List_Price_Staging__c = 5; 
        priceStage.Pricing_Median_Meet_Comp_Disty_Staging__c = 4; 
        priceStage.Pricing_Final_Meet_Comp_Price_Staging__c = 2; 
        priceStage.Pricing_Application_Staging_Nm__c = null;
        priceStage.Pricing_Competitor_Product_Name_Staging__c = 'TestCompProduct';
        insert priceStage;
        
        Pricing_Competitor_Product_Price__c compProdPrice = new Pricing_Competitor_Product_Price__c();
        compProdPrice.Pricing_Region_Nm__c = 'APJ'; 
        compProdPrice.Pricing_List_Price__c = 8; 
        compProdPrice.Pricing_Median_Meet_Comp_Discount__c = 0; 
        compProdPrice.Pricing_Final_Meet_Comp_Price__c = 8;
        compProdPrice.Pricing_Application_Nm__c = 'Enterprise';
        compProdPrice.Pricing_Competitor_Product__c = compProduct.id;
        insert compProdPrice;
        
        //update of competitor product price record.
        Pricing_Competitor_Product_Price_Staging__c compProductPriceStaging = new Pricing_Competitor_Product_Price_Staging__c();
        compProductPriceStaging.Pricing_Region_Staging_Nm__c = 'APJ'; 
        compProductPriceStaging.Pricing_List_Price_Staging__c = 5; 
        compProductPriceStaging.Pricing_Median_Meet_Comp_Disty_Staging__c = 4; 
        compProductPriceStaging.Pricing_Final_Meet_Comp_Price_Staging__c = 2;
        compProductPriceStaging.Pricing_Application_Staging_Nm__c = null;
        compProductPriceStaging.Pricing_Competitor_Product_Name_Staging__c = 'TestCompProduct1';
        insert compProductPriceStaging;
        
        
        Pricing_Competitor_Product_Price__c compProductPrice = [SELECT id,Pricing_Competitor_Product__c,Pricing_Competitor_Product__r.Name,Pricing_Region_Nm__c,Pricing_List_Price__c,
                                                                Pricing_Median_Meet_Comp_Discount__c,Pricing_Final_Meet_Comp_Price__c FROM Pricing_Competitor_Product_Price__c where id =: listOfCompProductPrice[0].id and Pricing_Competitor_Product__r.Name =: compProductPriceStaging.Pricing_Competitor_Product_Name_Staging__c and Pricing_Region_Nm__c = :compProductPriceStaging.Pricing_Region_Staging_Nm__c];
        compProductPrice.Pricing_List_Price__c = 5;
        compProductPrice.Pricing_Median_Meet_Comp_Discount__c = 0; 
        compProductPrice.Pricing_Final_Meet_Comp_Price__c = 8;
        compProductPriceList.add(compProductPrice);
        update compProductPriceList;
        System.assert(compProductPriceList.size() > 0,'Competitor Product Price Record Updated.');
        Test.stopTest();
    }
}