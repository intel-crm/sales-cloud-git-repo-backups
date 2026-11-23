/**************************************************************************************
Apex Class Name:  Core_ApproveRejectDR_LexController_Test
Version     : 1.0 
Created Date: 18 Jun 2018
Function    : Test Class for the Core_ApproveRejectDR_LexController class
Modification Log :
* Developer                       Date                   Description
* ----------------------------------------------------------------------------                 
* Ragamalika Mohanraj             18/06/2018             Original Version
*************************************************************************************/
@isTest
public class Core_ApproveRejectDR_LexController_Test {
     public static testmethod void DR_Product_test1() {
         
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
         
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(6, DDRLst, ProdLst);
        insert DRPLst;
        
        DRPLst[0].Core_Design_Product_Status_Nm__c = 'Approved';
        DRPLst[1].Core_Locked_Ind__c = true;
        DRPLst[3].Core_Design_Product_Status_Nm__c = 'Rejected';
        DRPLst[4].Core_Locked_Ind__c = true;
        
        update DRPLst;
        
        Test.startTest();
        Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[0].Id);
        Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[1].Id);
        Core_ApproveRejectDR_LexController.approveDesignReg(DRPLst[2].Id);
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[3].Id);
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[4].Id);
        Core_ApproveRejectDR_LexController.rejectDesignReg(DRPLst[5].Id);
        Test.stopTest();
        
     
     }
}