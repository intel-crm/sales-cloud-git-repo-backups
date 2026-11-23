@isTest(seeAllData = false)
public class Core_DDR_Approve_Design_Controller_Test
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
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(1);
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
        
        List<Core_Design_Registration_Product__c> TestDDRProdReSubmit = Core_DDR_Utility.CreateDRProduct(1, TestDDRlst, products2);
        insert TestDDRProdReSubmit;
        
        Core_Design_Registration__c DDR = new Core_Design_Registration__c();
        DDR.id = TestDDRupdate[0].id;
        update DDR;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(DDR);
        Core_DDR_Approve_Design_Controller DDR_Approve = new Core_DDR_Approve_Design_Controller(Sc);
        PageReference pageRef = Page.Core_DDR_Approve_Design; 
        pageRef.getParameters().put('id', TestDDRupdate[0].id);
        Test.setCurrentPage(pageRef);       
        DDR_Approve.ApproveReSubmitedDR();
    }
    
    public static testmethod void ExceptionTest() {
        List<account> LstAcc = Core_Test_Utility.createAccount(5);
        insert LstAcc;
        
        Pricebook2 standardPricebook = new Pricebook2(Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;
        
        Core_Location_To_Approver_Group_Mapping__c locationToApproverGrp = new Core_Location_To_Approver_Group_Mapping__c(name = 'USA-OR', Core_Active_Ind__c = true, Core_Country_Cd__c = 'USA', Core_Approver_Group_Nm__c = 'Core_Design_Approver_USA_Oregon', Core_State_Cd__c = 'OR');
        insert locationToApproverGrp;
        
        List<Product2> products2 = Core_DDR_Utility.CreateProduct(5);
        insert products2;
        
        List<Core_Design_Registration__c> TestDDRlst = Core_DDR_Utility.createDDR(5);
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
            //upDDR.Core_Partner_Account_Id__c = LstAcc[0].id;
            upDDR.Core_Opportunity_Decision_Dt__c = system.today();
            TestDDRupdate.add(upDDR);
        }
        Test.startTest();
        update TestDDRupdate;
        
        List<Core_Design_Registration_Product__c> TestDDRProdRej = Core_DDR_Utility.CreateDRProduct(5, TestDDRlst, products2);
        insert TestDDRProdRej;
        
        List<Core_Design_Registration_Product__c> DRP_Approve_Update = new List<Core_Design_Registration_Product__c>();
        
        for(Core_Design_Registration_Product__c pupdate: TestDDRProdRej){
            pupdate.Core_Design_Product_Status_Nm__c = 'Approved';
            DRP_Approve_Update.add(pupdate);
        }
        update DRP_Approve_Update;
        
        Core_Design_Registration__c DDR = new Core_Design_Registration__c();
        DDR.id = TestDDRupdate[0].id;
        update DDR;        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(DDR);
        Core_DDR_Approve_Design_Controller DDR_Approve = new Core_DDR_Approve_Design_Controller(Sc);
        PageReference pageRef = Page.Core_DDR_Approve_Design; 
        pageRef.getParameters().put('id', TestDDRupdate[0].id);
        Test.setCurrentPage(pageRef);       
        DDR_Approve.ApproveReSubmitedDR();
    }
}