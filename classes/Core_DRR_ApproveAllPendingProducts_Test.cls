/**************************************************************************************
Apex Class Name:  Core_DRR_ApproveAllPendingProducts_Test
Version     : 1.0 
Created Date: 18 Jun 2018
Function    : Test Class for Core_DRR_ApproveAllPendingProducts
Modification Log :
* Developer                       Date                    Description
* ----------------------------------------------------------------------------                 
* Ragamalika Mohanraj             18/06/2014              Original Version
*************************************************************************************/
@isTest
public class Core_DRR_ApproveAllPendingProducts_Test {
     public static testmethod void DR_Product_test1() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Pending';
            DRP.Core_Locked_Ind__c = false;
        }
        
        update DRPLst;
        
        Test.startTest();
        Test.setCurrentPage(Page.Core_DRR_ApproveAllPendingProdListButton); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_DRR_ApproveAllPendingProducts drr =  new Core_DRR_ApproveAllPendingProducts(stdSetController);
        drr.approvalAllpendingProd();
        delete DRPLst;
        drr.approvalAllpendingProd();
        Test.stopTest();
        
     
     }
    
         public static testmethod void DR_Product_test2() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(1);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Pending';
            DRP.Core_Locked_Ind__c = false;
        }
        
        update DRPLst;
        ProdLst[0].isActive=false;
        update  ProdLst[0];
         
        Test.startTest();
        Test.setCurrentPage(Page.Core_DRR_ApproveAllPendingProdListButton); 
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(DRPLst);
        stdSetController.setSelected(DRPLst);
        ApexPages.currentPage().getParameters().put('Id',DRPLst[0].Core_Design_Registration_Id__c);
        Core_DRR_ApproveAllPendingProducts drr =  new Core_DRR_ApproveAllPendingProducts(stdSetController);
        drr.approvalAllpendingProd();
        delete DRPLst;
        drr.approvalAllpendingProd();
        Test.stopTest();
        
     
     }
}