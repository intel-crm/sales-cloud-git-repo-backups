@isTest(seeAllData = false)
public class Core_DDR_Cancel_Product_Controller_Test
{
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
        
        List<Opportunity> OppList = Core_Test_Utility.Core_Opportunity(1);
        OppList[0].Pricebook2Id = PriceBookLst[0].id;
        OppList[0].AccountID = LstAcc[0].id;
        OppList[0].Core_Intel_Platform__c = 'Bakerville';
        insert OppList;
        
        OpportunityLineItem tempOppLI = new OpportunityLineItem(OpportunityId = OppList[0].id, Core_Design_Registration_Product_Id__c = DRPLst[0].Id, UnitPrice = 5, Quantity = 4, Product2ID = ProdLst[0].id);
        insert tempOppLI;
        
        OpportunityLineItem tempOppLI2 = new OpportunityLineItem(OpportunityId = OppList[0].id, Core_Design_Registration_Product_Id__c = DRPLst[1].Id, UnitPrice = 5, Quantity = 4, Product2ID = ProdLst[1].id);
        insert tempOppLI2;  
        
        tempOppLI2.Core_Status__c = 'Production Win';
        update tempOppLI2;      
        
        Core_Design_Registration_Product__c DRP = new Core_Design_Registration_Product__c();
        DRP.id = DRPLst[0].id;
        update DRP;
        
        Core_Design_Registration_Product__c DRP1 = new Core_Design_Registration_Product__c();
        DRP1.id = DRPLst[1].id;
        update DRP1;
        
        Core_Design_Registration_Product__c DRP2 = new Core_Design_Registration_Product__c();
        DRP1.Core_Design_Product_Status_Nm__c = 'Pending';
        update DRP1;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(DRP1);
        Core_DDR_Cancel_Product_Controller CancelDDR_Product = new Core_DDR_Cancel_Product_Controller(Sc);
        PageReference pageRef = Page.Core_DDR_Cancel_Product; 
        pageRef.getParameters().put('id', DRP1.id);
        Test.setCurrentPage(pageRef);       
        CancelDDR_Product.cancelDDRProduct();
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(DRP1);
        Core_DDR_Cancel_Product_Controller CancelDDR_Product1 = new Core_DDR_Cancel_Product_Controller(Sc);
        PageReference pageRef1 = Page.Core_DDR_Cancel_Product; 
        pageRef1.getParameters().put('id', DRP1.id);
        Test.setCurrentPage(pageRef1);       
        CancelDDR_Product.cancelDDRProduct();
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(DRP);
        Core_DDR_Cancel_Product_Controller CancelDDR_Product2 = new Core_DDR_Cancel_Product_Controller(Sc2);
        PageReference pageRef2 = Page.Core_DDR_Cancel_Product; 
        pageRef2.getParameters().put('id', DRP.id);
        Test.setCurrentPage(pageRef2);
        CancelDDR_Product2.cancelDDRProduct();
        
        ApexPages.StandardController sc3 = new ApexPages.StandardController(DRP2);
        Core_DDR_Cancel_Product_Controller CancelDDR_Product3 = new Core_DDR_Cancel_Product_Controller(Sc2);
        PageReference pageRef3 = Page.Core_DDR_Cancel_Product; 
        pageRef3.getParameters().put('id', 'DRP2.Core_Design_Product_Status_Nm__c');
        Test.setCurrentPage(pageRef3);
        CancelDDR_Product3.cancelDDRProduct();
        
        test.stoptest();
    }
}