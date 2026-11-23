@isTest(seeAllData = false)
public class Core_DDR_Cancel_Product_Controller_Test
{
    public static testmethod void DR_Product_test1() {
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        insert LstAcc;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        
        Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_Design_Approver_USA_Oregon', Core_State_Cd__c = 'OR');
        insert locationToApproverGrp;
        
        List<Product2> products2 = Core_DDR_Utility.CreateProduct(5);
        insert products2;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(1, LstAcc);
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(1, TestDDRlst, products2);
        insert TestDDRProd; 
        
        List<Core_Design_Registration_Product__c> DRP_Update = new List<Core_Design_Registration_Product__c>();
        
        for(Core_Design_Registration_Product__c pupdate: TestDDRProd){
            pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP_Update.add(pupdate);
        }
        update DRP_Update;
        
        List<Core_Design_Registration__c> TestDDRupdate = new List<Core_Design_Registration__c>();
        
        for(Core_Design_Registration__c upDDR: TestDDRlst){
            upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
            upDDR.Core_Product_Segment_Nm__c = 'Embedded';
            upDDR.Core_Product_Application_Nm__c = 'Energy - Other';
            upDDR.Core_Partner_Account_Id__c = LstAcc[0].id;
            TestDDRupdate.add(upDDR);
        }
        update TestDDRupdate;
        
        TestDDRProd[0].Core_Design_Product_Status_Nm__c = 'Cancelled';
        update TestDDRProd;
        
        Core_Design_Registration_Product__c DRP = new Core_Design_Registration_Product__c();
        DRP.id = DRP_Update[0].id;
        update DRP;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(DRP);
        Core_DDR_Cancel_Product_Controller CancelDDR_Product = new Core_DDR_Cancel_Product_Controller(Sc);
        PageReference pageRef = Page.Core_DDR_Cancel_Product; 
        pageRef.getParameters().put('id', TestDDRProd[0].id);
        Test.setCurrentPage(pageRef);       
        CancelDDR_Product.cancelDDRProduct();
    }
    
    public static testmethod void DR_Product_test2() {
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        insert LstAcc;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        
        Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_Design_Approver_USA_Oregon', Core_State_Cd__c = 'OR');
        insert locationToApproverGrp;
        
        List<Product2> products2 = Core_DDR_Utility.CreateProduct(5);
        insert products2;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(1, LstAcc);
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(1, TestDDRlst, products2);
        insert TestDDRProd; 
        
        List<Core_Design_Registration_Product__c> DRP_Update = new List<Core_Design_Registration_Product__c>();
        
        for(Core_Design_Registration_Product__c pupdate: TestDDRProd){
            pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP_Update.add(pupdate);
        }
        update DRP_Update;
        
        List<Core_Design_Registration__c> TestDDRupdate = new List<Core_Design_Registration__c>();
        
        for(Core_Design_Registration__c upDDR: TestDDRlst){
            upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
            upDDR.Core_Product_Segment_Nm__c = 'Embedded';
            upDDR.Core_Product_Application_Nm__c = 'Energy - Other';
            upDDR.Core_Partner_Account_Id__c = LstAcc[0].id;
            TestDDRupdate.add(upDDR);
        }
        update TestDDRupdate;
        
        Core_Design_Registration_Product__c DRP = new Core_Design_Registration_Product__c();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(DRP);
        Core_DDR_Cancel_Product_Controller CancelDDR_Product = new Core_DDR_Cancel_Product_Controller(Sc);
        PageReference pageRef = Page.Core_DDR_Cancel_Product; 
        pageRef.getParameters().put('id', TestDDRProd[0].id);
        Test.setCurrentPage(pageRef);       
        CancelDDR_Product.cancelDDRProduct();
    }
    
    public static testmethod void ExceptionTest() {
        
        Core_Design_Registration_Product__c DRP = new Core_Design_Registration_Product__c();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(DRP);
        Core_DDR_Cancel_Product_Controller CancelDDR_Product = new Core_DDR_Cancel_Product_Controller(Sc);
        PageReference pageRef = Page.Core_DDR_Cancel_Product; 
        pageRef.getParameters().put('id', 'test');
        Test.setCurrentPage(pageRef);       
        CancelDDR_Product.cancelDDRProduct();    
    }
}