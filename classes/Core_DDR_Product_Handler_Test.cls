@isTest
public class Core_DDR_Product_Handler_Test
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
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5, LstAcc);
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
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
        Test.startTest();
        update TestDDRupdate;
        
        List<Core_Design_Registration_Product__c> TestDDRProd2 = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
        insert TestDDRProd2;
        
        for(Core_Design_Registration_Product__c pupdate: TestDDRProd2){
            pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP_Update.add(pupdate);
        }
        update DRP_Update;
        
        List<Core_Design_Registration__c> TestDDRupdate2 = new List<Core_Design_Registration__c>();
        for(Core_Design_Registration__c upDDR: TestDDRlst){
            upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
            TestDDRupdate2.add(upDDR);
        }
        update TestDDRupdate2;
        
        Test.stopTest(); 
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
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5, LstAcc);
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
        insert TestDDRProd; 
        
        List<Core_Design_Registration_Product__c> DRP_Update = new List<Core_Design_Registration_Product__c>();
        
        for(Core_Design_Registration_Product__c pupdate: TestDDRProd){
            pupdate.Core_Design_Product_Status_Nm__c = 'Rejected';
            DRP_Update.add(pupdate);
        }
        update DRP_Update;
        
        List<Core_Design_Registration__c> TestDDRupdate = new List<Core_Design_Registration__c>();
        
        for(Core_Design_Registration__c upDDR: TestDDRlst){
            upDDR.Core_Design_Registration_Status_Nm__c = 'Rejected';
            upDDR.Core_Rejection_Comment_Txt__c = 'Embedded';
            upDDR.Core_Rejection_Reason_Nm__c = 'Duplicate registration';
            upDDR.Core_Partner_Account_Id__c = LstAcc[0].id;
            TestDDRupdate.add(upDDR);
        }
        Test.startTest();
        update TestDDRupdate;
        
        List<Core_Design_Registration_Product__c> TestDDRProdRej = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
        insert TestDDRProdRej;
        
        List<Core_Design_Registration_Product__c> DRP_UpdateRej = new List<Core_Design_Registration_Product__c>();
        
        for(Core_Design_Registration_Product__c pupdate: TestDDRProdRej){
            pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP_UpdateRej.add(pupdate);
        }
        update DRP_UpdateRej;
        
        List<Core_Design_Registration__c> TestDDRupdate_Rej = new List<Core_Design_Registration__c>();
        
        for(Core_Design_Registration__c upDDR: TestDDRlst){
            upDDR.Core_Design_Registration_Status_Nm__c = 'Approved';
            upDDR.Core_Product_Segment_Nm__c = 'Embedded';
            upDDR.Core_Product_Application_Nm__c = 'Energy - Other';
            upDDR.Core_Partner_Account_Id__c = LstAcc[0].id;
            TestDDRupdate_Rej.add(upDDR);
        }
        update TestDDRupdate_Rej;
        
        Test.stopTest();
    }
    
    public static testmethod void DR_Product_Exc() {
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        insert LstAcc;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        
        Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_Design_Approver_USA_Oregon', Core_State_Cd__c = 'OR');
        insert locationToApproverGrp;
        
        List<Product2> products2 = Core_DDR_Utility.CreateProduct(5);
        insert products2;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5, LstAcc);
        insert TestDDRlst;
        
        List<Core_Design_Registration_Product__c> TestDDRProd = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
        for(Core_Design_Registration_Product__c prod: TestDDRProd){
            prod.Core_Design_Product_Status_Nm__c = 'Cancelled';
        }
        insert TestDDRProd;
    }
    
}