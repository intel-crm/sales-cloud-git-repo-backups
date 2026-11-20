/*-------------------------------------------------------------------------------------------
Apex Class  : Core_DR_Zero_Quantity_msg_Ctrl_Test
Version     : 1.0 
Created Date:   10 Oct 2020
Function    : test class for Core_DR_Zero_Quantity_msg_Ctrl To show the warning message for zero quantity DR products
Modification Log :
* Developer                  Date                   Description
* ----------------------------------------------------------------------------                 
* Mahesh Manikonda           10/10/2020             Original version
--------------------------------------------------------------------------------------------*/

@isTest
public class Core_DR_Zero_Quantity_msg_Ctrl_Test {
    
     public static testmethod void DR_Product_test1() {
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'GMP India Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'GMP India Sales Group';
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
        }
        update DRPLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        Test.startTest();

         ApexPages.StandardController sc11 = new ApexPages.StandardController(DDRLst[0]);
        Core_DR_Zero_Quantity_msg_Ctrl DDRWarniMsg = new Core_DR_Zero_Quantity_msg_Ctrl(Sc11);
         Core_DR_Zero_Quantity_msg_Ctrl.ValidateZeroProducts(DDRLst[0].id);
        
        test.stoptest();
    }
    
         public static testmethod void DR_Product_test2() {
        List<account> LstAcc = Core_Test_Utility.createAccount(2);
        LstAcc[0].Core_Sales_Groups__c = 'GMP India Sales Group';
        lstAcc[1].Core_Sales_Groups__c = 'GMP India Sales Group';
        insert LstAcc;
        
        List<Core_Location_To_Approver_Group_Mapping__c> LocToAppGroup = Core_DDR_Utility.CreateLocationToApproverGroup();
        
        List<Core_LogEntry_Switch__c> LogEntryCS = Core_DDR_Utility.CreateLogEntry();
        
        List<Product2> ProdLst = Core_DDR_Utility.CreateProduct(5);
        insert ProdLst;
        
        List<PriceBook2> PriceBookLst = Core_DDR_Utility.CreatePriceBook2();
        insert PriceBookLst;
        
        List<PriceBookEntry> PBELst = Core_DDR_Utility.CreatePriceBookEntry(5, ProdLst, PriceBookLst);
        
        List<Core_Design_Registration__c> DDRLst = Core_DDR_Utility.createDDR(5);
        DDRLst[0].Core_Product_Group_Nm__c = 'Embedded/IOT';
        insert DDRLst;
        
        List<Core_Design_Registration_Product__c> DRPLst = Core_DDR_Utility.CreateDRProduct(5, DDRLst, ProdLst);
        insert DRPLst;
        
        for(Core_Design_Registration_Product__c DRP : DRPLst){
            DRP.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP.Core_Full_Year_Qty__c=0;
        }
        update DRPLst;
        
        for(Core_Design_Registration__c Design: DDRLst){
            Design.Core_Design_Registration_Status_Nm__c = 'Approved';
            Design.Core_End_Customer_Account_Id__c = LstAcc[0].id;
            Design.Core_Partner_Account_Id__c = LstAcc[1].id;
        }        
        update DDRLst;
        Test.startTest();

         ApexPages.StandardController sc11 = new ApexPages.StandardController(DDRLst[0]);
        Core_DR_Zero_Quantity_msg_Ctrl DDRWarniMsg = new Core_DR_Zero_Quantity_msg_Ctrl(Sc11);
         Core_DR_Zero_Quantity_msg_Ctrl.ValidateZeroProducts(DDRLst[0].id);
        
        test.stoptest();
    }

}