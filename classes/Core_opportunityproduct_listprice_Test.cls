/******************************************************************************************************************************************
Class Name  : Core_opportunityproduct_listprice_Test
Version     : 1.0 
Created Date: July 13, 2022
Function    : Test class for Core_opportunityproduct_listprice_contrl 
Modification Log :
* Developer         Date          Description
* ----------------------------------------------------------------------------                 
* Mula Yeshwanth        13/07/2022   Original version
*****************************************************************************************************************************************/

@isTest
public class Core_opportunityproduct_listprice_Test {
    
    public static testmethod void testOppprodlistPrice(){
        
       /* Opportunity opp = new Opportunity();
        opp.AccountId = 'Test acc_1';
        opp.Name='Test opp_7';
        opp.StageName='Develop';
        opp.CloseDate=System.Today();
        opp.Core_Opportunity_Type__c='Design: Secondary';
        opp.Core_Product_Segment__c='Client Computing';
        opp.Core_Military_Aerospace_Govmt_End_Use__c='No';
        opp.Core_Consumption_Market__c='Automotive';
        opp.Core_Commissionable__c='Yes';
        insert opp;*/
        
        Product2 prod = new Product2();
        prod.Name='Product U1';
        //prod.OpportunityId=opp.Id;
        prod.IsActive=true;
        insert prod;
        
        Pricebook2 pb = new Pricebook2();
        pb.Name='Standard Price Book2022';
        pb.Description='Price Book 2022 Products';
        pb.IsActive=true;        
        insert pb;
        
        /*PricebookEntry pbe = new PricebookEntry();
        pbe.Product2Id='100 SERIES B150';
        pbe.Pricebook2Id='Standard Price Book';
        pbe.Product2Id=prod.Id;
        pbe.Pricebook2Id=pb.Id;
        pbe.UnitPrice=200;
        pbe.IsActive=true;
        insert pbe; */       
        
        
        List<PriceBookEntry> entryList = new List<PriceBookEntry>  {
        new PricebookEntry( Product2Id=prod.id, UnitPrice=200,
                        PriceBook2Id=Test.getStandardPricebookId(), 
                        UseStandardPrice=false,isActive=true),
       new PricebookEntry( Product2Id=prod.id, UnitPrice=2000, 
                        PriceBook2Id=pb.id, 
                        UseStandardPrice=true,isActive=true)
                 };
                 insert entryList;
        
        entryList[0].UnitPrice = 300;
        entryList[1].Unitprice = 1000;
        update entryList;
        
       // Field FieldInstance = new Field();
        
        Test.StartTest();
        Core_opportunityproduct_listprice_contrl.getOpportunityLineItem();
        Test.StopTest();
    }

}